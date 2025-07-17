// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(distance) => "${distance}m away";

  static String m1(error) => "Error: ${error}";

  static String m2(error) => "Error: ${error}";

  static String m3(diamonds) => "Buy ${diamonds} 💎";

  static String m4(count) => "${count} comments";

  static String m5(count) => "${count} diamonds";

  static String m6(error) => "Error: ${error}";

  static String m7(error) => "❌ Error saving video: ${error}";

  static String m8(intent) => "Intent: ${intent}";

  static String m9(intent) => "Looking for ${intent} nearby";

  static String m10(emoji) => "${emoji} Match Found!";

  static String m11(emoji, mood) => "${emoji} ${mood}";

  static String m12(price) => "Suggested price: ${price} 💎";

  static String m13(error) => "Recording error: ${error}";

  static String m14(count) =>
      "${count} ${Intl.plural(count, one: 'reply', other: 'replies')}";

  static String m15(username) => "Replying to ${username}";

  static String m16(email) => "📧 Reset email sent to ${email}";

  static String m17(error) => "Selection error: ${error}";

  static String m18(caption, username) =>
      "🎬 Check out this video on Dadadu!\n\"${caption}\"\nBy @${username}\n\n📱 Authentic video app without likes or views\n#Dadadu #Authentic #Local";

  static String m19(error) => "❌ Error sharing: ${error}";

  static String m20(error) => "Error while sharing: ${error}";

  static String m21(username) => "${username}’s Dadadu Profile";

  static String m22(username, profileUrl) =>
      "🎬 Check out ${username}’s profile on Dadadu!\nAn app for authentic short videos without likes or views.\n${profileUrl}\n\n#Dadadu #Profile";

  static String m23(referralLink) =>
      "🎬 Join me on Dadadu! A short video app with no likes, just realness. Use my referral link to earn 100 💎: ${referralLink}\n\n#Dadadu #Authentic #NoViews";

  static String m24(error) => "Stop recording error: ${error}";

  static String m25(username) => "${username} commented on your video";

  static String m26(error) => "Video loading error: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addComment": MessageLookupByLibrary.simpleMessage("Add a comment..."),
    "away": m0,
    "badgeDadalordDesc": MessageLookupByLibrary.simpleMessage(
      "Elite status worth \\\$10,000+ with +2% per million diamonds",
    ),
    "badgeDadalordTitle": MessageLookupByLibrary.simpleMessage(
      "DADALORD (10M+)",
    ),
    "badgeFiveleafDesc": MessageLookupByLibrary.simpleMessage(
      "Popular creator status",
    ),
    "badgeFiveleafTitle": MessageLookupByLibrary.simpleMessage(
      "FIVELEAF (1M–9.9M)",
    ),
    "badgeLeafDesc": MessageLookupByLibrary.simpleMessage(
      "Starting level for new users",
    ),
    "badgeLeafTitle": MessageLookupByLibrary.simpleMessage(
      "LEAF (0–9,999 diamonds)",
    ),
    "badgeListed": MessageLookupByLibrary.simpleMessage(
      "Badge listed successfully!",
    ),
    "badgeListingError": m1,
    "badgeMarketplace": MessageLookupByLibrary.simpleMessage(
      "Badge Marketplace",
    ),
    "badgeNote": MessageLookupByLibrary.simpleMessage(
      "📈 Higher badges = more prestige + marketplace value",
    ),
    "badgePurchaseError": m2,
    "badgePurchased": MessageLookupByLibrary.simpleMessage(
      "Badge purchased successfully!",
    ),
    "badgeSystemTitle": MessageLookupByLibrary.simpleMessage(
      "🏆 DADADU BADGE SYSTEM",
    ),
    "badgeThreeleafDesc": MessageLookupByLibrary.simpleMessage(
      "Active community member",
    ),
    "badgeThreeleafTitle": MessageLookupByLibrary.simpleMessage(
      "THREELEAF (10K–999K)",
    ),
    "buy": MessageLookupByLibrary.simpleMessage("Buy"),
    "buyForDiamonds": m3,
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSearch": MessageLookupByLibrary.simpleMessage("Cancel Search"),
    "captionHint": MessageLookupByLibrary.simpleMessage(
      "Describe your video...\nWhat do you want to share?",
    ),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changeUsername": MessageLookupByLibrary.simpleMessage("Change Username"),
    "changeUsernameHint": MessageLookupByLibrary.simpleMessage(
      "Enter your new name",
    ),
    "changeUsernameTitle": MessageLookupByLibrary.simpleMessage("New username"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "commentError": MessageLookupByLibrary.simpleMessage(
      "Error sending comment",
    ),
    "commentPosted": MessageLookupByLibrary.simpleMessage("💬 Comment posted!"),
    "commentsCount": m4,
    "commentsTitle": MessageLookupByLibrary.simpleMessage("💬 Comments"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "contactLabel": MessageLookupByLibrary.simpleMessage("Contact for matches"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "createDadaduVideo": MessageLookupByLibrary.simpleMessage(
      "Create your Dadadu video",
    ),
    "createVideoTitle": MessageLookupByLibrary.simpleMessage("Create Video"),
    "createYourDadaduID": MessageLookupByLibrary.simpleMessage(
      "Create your Dadadu ID 🚀",
    ),
    "creating": MessageLookupByLibrary.simpleMessage("Creating..."),
    "creator": MessageLookupByLibrary.simpleMessage("CREATOR"),
    "cropAndSave": MessageLookupByLibrary.simpleMessage("Crop & Save"),
    "cropFailed": MessageLookupByLibrary.simpleMessage("Failed to crop image"),
    "cropImage": MessageLookupByLibrary.simpleMessage("Crop Image"),
    "cropping": MessageLookupByLibrary.simpleMessage("Cropping..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark mode"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "descriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description (optional)",
    ),
    "diamonds": m5,
    "diamondsProfile": MessageLookupByLibrary.simpleMessage("Diamonds"),
    "discover": MessageLookupByLibrary.simpleMessage("Discover"),
    "discoverConfigError": MessageLookupByLibrary.simpleMessage(
      "❌ Error while saving configuration",
    ),
    "discoverConfigTitle": MessageLookupByLibrary.simpleMessage(
      "Discover Configuration",
    ),
    "discoverConfigUpdated": MessageLookupByLibrary.simpleMessage(
      "🎯 Discover configuration updated",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloading": MessageLookupByLibrary.simpleMessage("📥 Downloading..."),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "enterOtpMessage": MessageLookupByLibrary.simpleMessage(
      "Enter the OTP sent to your phone",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorRemovingListing": m6,
    "errorSavingVideo": m7,
    "feedAnalyzingPreferences": MessageLookupByLibrary.simpleMessage(
      "Analyzing your preferences",
    ),
    "feedPersonalizing": MessageLookupByLibrary.simpleMessage(
      "Personalizing your feed...",
    ),
    "follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "followCreators": MessageLookupByLibrary.simpleMessage(
      "Follow creators to see their content",
    ),
    "followers": MessageLookupByLibrary.simpleMessage("Followers"),
    "following": MessageLookupByLibrary.simpleMessage("Following"),
    "followingStatus": MessageLookupByLibrary.simpleMessage("Following"),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "generalSection": MessageLookupByLibrary.simpleMessage("General"),
    "genericError": MessageLookupByLibrary.simpleMessage(
      "An error occurred. Please try again.",
    ),
    "goodMatch": MessageLookupByLibrary.simpleMessage("Good Match"),
    "gotIt": MessageLookupByLibrary.simpleMessage("Got it"),
    "greatButton": MessageLookupByLibrary.simpleMessage("Great!"),
    "greatMatch": MessageLookupByLibrary.simpleMessage("Great Match"),
    "howBadgesWork": MessageLookupByLibrary.simpleMessage("How Badges Work"),
    "identifierHint": MessageLookupByLibrary.simpleMessage("Your ID"),
    "imageReady": MessageLookupByLibrary.simpleMessage("Image ready!"),
    "imageSelectionError": MessageLookupByLibrary.simpleMessage(
      "❌ Error while selecting the image",
    ),
    "infoAddCaption": MessageLookupByLibrary.simpleMessage(
      "Add a caption to publish your video",
    ),
    "infoSelectOrRecord": MessageLookupByLibrary.simpleMessage(
      "Select or record a video to get started",
    ),
    "initializingCamera": MessageLookupByLibrary.simpleMessage(
      "Initializing camera...",
    ),
    "intent": MessageLookupByLibrary.simpleMessage("Intent"),
    "intentBusiness": MessageLookupByLibrary.simpleMessage("business"),
    "intentEntertainment": MessageLookupByLibrary.simpleMessage(
      "entertainment",
    ),
    "intentFun": MessageLookupByLibrary.simpleMessage("Fun"),
    "intentInformative": MessageLookupByLibrary.simpleMessage("Informative"),
    "intentLove": MessageLookupByLibrary.simpleMessage("love"),
    "intentSerious": MessageLookupByLibrary.simpleMessage("Serious"),
    "intentWith": m8,
    "interestFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to express interest",
    ),
    "interestSentWaiting": MessageLookupByLibrary.simpleMessage(
      "Interest sent! Waiting for response...",
    ),
    "interested": MessageLookupByLibrary.simpleMessage("I\'m Interested"),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number (with +country code)",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Light mode"),
    "listingRemoved": MessageLookupByLibrary.simpleMessage("Listing removed"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "loadingImage": MessageLookupByLibrary.simpleMessage("Loading image..."),
    "locationPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "📍 Location access needed for matching nearby users",
    ),
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required for matching",
    ),
    "login": MessageLookupByLibrary.simpleMessage("LOGIN"),
    "logout": MessageLookupByLibrary.simpleMessage("Log Out"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "logoutDescription": MessageLookupByLibrary.simpleMessage(
      "Sign out of the app",
    ),
    "lookingForIntentNearby": m9,
    "matchFound": m10,
    "matchHistory": MessageLookupByLibrary.simpleMessage("Match History"),
    "matchedWith": MessageLookupByLibrary.simpleMessage("Matched with"),
    "maximum20Seconds": MessageLookupByLibrary.simpleMessage(
      "Maximum 20 seconds",
    ),
    "mood": m11,
    "moodProfile": MessageLookupByLibrary.simpleMessage("Mood"),
    "mustBeLoggedIn": MessageLookupByLibrary.simpleMessage(
      "You must be logged in to comment",
    ),
    "mutualMatchTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Mutual Match!",
    ),
    "myBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "My badges for sale",
    ),
    "myVideos": MessageLookupByLibrary.simpleMessage("My Videos"),
    "navNow": MessageLookupByLibrary.simpleMessage("Now"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "navUpload": MessageLookupByLibrary.simpleMessage("Upload"),
    "newCommentNotification": MessageLookupByLibrary.simpleMessage(
      "💬 New comment",
    ),
    "newUsernameHint": MessageLookupByLibrary.simpleMessage("New username"),
    "noAccountSignUp": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account? Sign up",
    ),
    "noBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "No badges for sale",
    ),
    "noCommentsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Share your thoughts about this video",
    ),
    "noCommentsTitle": MessageLookupByLibrary.simpleMessage(
      "Be the first to comment!",
    ),
    "noContactInfo": MessageLookupByLibrary.simpleMessage("No contact info"),
    "noImageLoaded": MessageLookupByLibrary.simpleMessage("No image loaded"),
    "noMatchHistory": MessageLookupByLibrary.simpleMessage("No match history."),
    "noMatchesFoundNearby": MessageLookupByLibrary.simpleMessage(
      "No matches found nearby",
    ),
    "noPhoto": MessageLookupByLibrary.simpleMessage("No photo"),
    "noVideoSelected": MessageLookupByLibrary.simpleMessage(
      "No video selected",
    ),
    "noVideos": MessageLookupByLibrary.simpleMessage("No videos available"),
    "notConfigured": MessageLookupByLibrary.simpleMessage("Not configured"),
    "notDefined": MessageLookupByLibrary.simpleMessage("Not defined"),
    "notEnoughDiamonds": MessageLookupByLibrary.simpleMessage(
      "You don\'t have enough diamonds!",
    ),
    "nowLabel": MessageLookupByLibrary.simpleMessage("Now"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otpError": MessageLookupByLibrary.simpleMessage(
      "OTP incorrect. Please try again.",
    ),
    "otpHint": MessageLookupByLibrary.simpleMessage("6-digit code"),
    "ownBadgeSellError": MessageLookupByLibrary.simpleMessage(
      "You can only sell your own badges",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "perfectMatch": MessageLookupByLibrary.simpleMessage("Perfect Match"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "❌ Storage permission required",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "photoSet": MessageLookupByLibrary.simpleMessage("Photo set"),
    "pleaseAddCaption": MessageLookupByLibrary.simpleMessage(
      "Please add a caption",
    ),
    "priceHint": m12,
    "priceLabel": MessageLookupByLibrary.simpleMessage("Price in diamonds"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profilePhoto": MessageLookupByLibrary.simpleMessage("Profile Photo"),
    "profilePhotoRemoveError": MessageLookupByLibrary.simpleMessage(
      "❌ Error while removing profile photo",
    ),
    "profilePhotoRemoved": MessageLookupByLibrary.simpleMessage(
      "✅ Profile photo removed",
    ),
    "profilePhotoUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Error uploading profile photo",
    ),
    "profilePhotoUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Profile photo updated",
    ),
    "profileSection": MessageLookupByLibrary.simpleMessage("Profile"),
    "publishVideoButton": MessageLookupByLibrary.simpleMessage("PUBLISH VIDEO"),
    "rank": MessageLookupByLibrary.simpleMessage("Rank"),
    "recordingError": m13,
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "referFriends": MessageLookupByLibrary.simpleMessage("Refer Friends"),
    "referralDescription": MessageLookupByLibrary.simpleMessage(
      "Earn 100 diamonds for every friend who joins Dadadu with your code!",
    ),
    "referralLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Referral link copied! 📋",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "repliesCount": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Reply"),
    "replyToComment": MessageLookupByLibrary.simpleMessage(
      "Reply to comment...",
    ),
    "replyingTo": m15,
    "resetEmailError": MessageLookupByLibrary.simpleMessage(
      "❌ Error sending the reset email",
    ),
    "resetEmailSent": m16,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
    "scanningForConnections": MessageLookupByLibrary.simpleMessage(
      "Scanning for connections...",
    ),
    "searchFailed": MessageLookupByLibrary.simpleMessage("Search failed"),
    "securitySection": MessageLookupByLibrary.simpleMessage("Security"),
    "selectIntent": MessageLookupByLibrary.simpleMessage("Select your intent"),
    "selectionError": m17,
    "sell": MessageLookupByLibrary.simpleMessage("Sell"),
    "sellBadgeTitle": MessageLookupByLibrary.simpleMessage("Sell your badge"),
    "sellButton": MessageLookupByLibrary.simpleMessage("List for sale"),
    "sellCurrentBadgeTitle": MessageLookupByLibrary.simpleMessage(
      "Sell my current badge",
    ),
    "sendResetEmail": MessageLookupByLibrary.simpleMessage(
      "Send password reset email",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "setupDiscover": MessageLookupByLibrary.simpleMessage("Configure Discover"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "shareBaseText": m18,
    "shareError": m19,
    "shareFacebookSuffix": MessageLookupByLibrary.simpleMessage(
      "🌟 Join the authentic content revolution!",
    ),
    "shareInstagramSuffix": MessageLookupByLibrary.simpleMessage(
      "📲 #DadaduApp #NoLikes #RealContent",
    ),
    "shareProfileError": m20,
    "shareProfileSubject": m21,
    "shareProfileText": m22,
    "shareReferralSubject": MessageLookupByLibrary.simpleMessage(
      "Join me on Dadadu!",
    ),
    "shareReferralText": m23,
    "shareSnapchatSuffix": MessageLookupByLibrary.simpleMessage(
      "👻 No more algorithm, more real!",
    ),
    "shareVideo": MessageLookupByLibrary.simpleMessage("📤 Share this video"),
    "shareWhatsAppSuffix": MessageLookupByLibrary.simpleMessage(
      "💎 Download Dadadu and earn diamonds!",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("SIGN UP"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "socialNetworkLabel": MessageLookupByLibrary.simpleMessage(
      "Social network",
    ),
    "sortPopular": MessageLookupByLibrary.simpleMessage("🔥 Popular"),
    "sortRecent": MessageLookupByLibrary.simpleMessage("🕒 Recent"),
    "sortTrending": MessageLookupByLibrary.simpleMessage("📈 Trending"),
    "stopRecordingError": m24,
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "trimContinue": MessageLookupByLibrary.simpleMessage("Trim and Continue"),
    "trimTitle": MessageLookupByLibrary.simpleMessage("Trim Your Video"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "tryChangingIntentOrLater": MessageLookupByLibrary.simpleMessage(
      "Try changing your intent or check back later",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "uploadError": MessageLookupByLibrary.simpleMessage("Upload error"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "userCommented": m25,
    "userNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "User not logged in",
    ),
    "userProfileNotFound": MessageLookupByLibrary.simpleMessage(
      "User profile not found",
    ),
    "userUnknown": MessageLookupByLibrary.simpleMessage("User"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Error updating username",
    ),
    "usernameUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Username updated",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "videoIntent": MessageLookupByLibrary.simpleMessage("Video Intent"),
    "videoLoadingError": m26,
    "videoPublishedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "🎉 Video published successfully!",
    ),
    "videoSaved": MessageLookupByLibrary.simpleMessage("✅ Saved to Downloads!"),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "videosOf": MessageLookupByLibrary.simpleMessage("Videos of"),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome back 👽"),
    "welcomeLogin": MessageLookupByLibrary.simpleMessage("Log In"),
    "welcomeSignUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "welcomeToDadadu": MessageLookupByLibrary.simpleMessage(
      "Welcome to Dadadu",
    ),
    "whatsYourVibe": MessageLookupByLibrary.simpleMessage(
      "What\'s your vibe today?",
    ),
    "yourBadge": MessageLookupByLibrary.simpleMessage("Your badge"),
  };
}
