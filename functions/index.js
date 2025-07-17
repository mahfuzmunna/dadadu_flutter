require("dotenv").config();
const admin = require("firebase-admin");
const {OpenAI} = require("openai");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onRequest} = require("firebase-functions/v2/https");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const cors = require("cors")({origin: true});
admin.initializeApp();

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/**
 * Classify a caption text for safety using OpenAI GPT-4.
 *
 * @param {string} text - The caption text to analyze.
 * @return {Promise<string>} One of "safe", "sensitive", or "blocked".
 */
async function classifyCaption(text) {
  const prompt = [
    "Analyze this user-submitted caption for safety:",
    `Text: "${text}"`,
    "",
    "Classify as one of: safe, sensitive, blocked",
  ].join("\n");

  console.log("Sending caption to OpenAI for moderation:", text);

  const response = await openai.chat.completions.create({
    model: "gpt-3.5-turbo",
    messages: [{role: "user", content: prompt}],
    temperature: 0.2,
  });

  const output = response.choices[0].message.content.toLowerCase();
  console.log("OpenAI moderation response:", output);

  if (output.includes("blocked")) return "blocked";
  if (output.includes("sensitive")) return "sensitive";
  return "safe";
}

exports.updateVideoVisibility = onSchedule("every 10 minutes", async () => {
  const db = admin.firestore();
  try {
    const snapshot = await db
        .collection("videos")
        .where("moderationStatus", "==", "safe")
        .get();

    if (snapshot.empty) {
      console.log("No videos to update visibility for.");
      return;
    }

    const batch = db.batch();

    snapshot.forEach((doc) => {
      const data = doc.data();
      let visibilityLevel = 0;
      let status = "hidden";

      if (data.diamonds >= 5) {
        visibilityLevel = 3;
        status = "active";
      } else if (data.diamonds >= 3) {
        visibilityLevel = 2;
        status = "active";
      } else if (data.diamonds >= 1) {
        visibilityLevel = 1;
        status = "active";
      }

      batch.update(doc.ref, {
        visibilityLevel,
        status,
        trending: visibilityLevel === 3,
      });
    });

    await batch.commit();
    console.log("Updated video visibility levels successfully.");
  } catch (error) {
    console.error("Error updating video visibility levels:", error);
  }
});

exports.moderateVideo = onDocumentCreated("videos/{videoId}", async (event) => {
  const data = event.data &&
  typeof event.data.data === "function" ?
  event.data.data() :
  null;
  if (!data) {
    console.warn("No data found in document created trigger");
    return;
  }

  const text = data.caption || "";
  if (!text) {
    console.log("No caption to moderate.");
    await event.data.ref.update({moderationStatus: "safe"});
    return;
  }

  try {
    const result = await classifyCaption(text);
    await event.data.ref.update({moderationStatus: result});
    console.log(`Moderationresultvideo ${event.params.videoId}: ${result}`);
  } catch (error) {
    console.error("Error during moderation:", error);
    await event.data.ref.update({moderationStatus: "error"});
  }
});


exports.createPaymentIntent = onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const {amount, currency, badgeId, buyerId, sellerId} = req.body;

      if (!amount || !currency || !badgeId || !buyerId || !sellerId) {
        return res.status(400).json({error: "Missing required fields"});
      }

      const paymentIntent = await stripe.paymentIntents.create({
        amount, // in cents
        currency,
        metadata: {
          badge_id: badgeId,
          buyer_id: buyerId,
          seller_id: sellerId,
        },
      });

      res.status(200).json({clientSecret: paymentIntent.client_secret});
    } catch (error) {
      console.error("Stripe error:", error);
      res.status(500).json({error: error.message});
    }
  });
});
