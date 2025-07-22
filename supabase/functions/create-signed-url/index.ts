// supabase/functions/create-signed-url/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  S3Client,
  PutObjectCommand,
  getSignedUrl, // Corrected import: getSignedUrl is directly from mod.ts
} from 'https://deno.land/x/s3_lite_client@0.2.0/mod.ts';

serve(async (req) => {
  // 1. Handle non-POST requests
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method Not Allowed' }),
      { status: 405, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // 2. Parse request body
  const { filename, contentType } = await req.json();

  // 3. Validate input
  if (!filename || !contentType) {
    return new Response(
      JSON.stringify({ error: 'Missing filename or contentType' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // 4. Authorize the request with Supabase Auth
  // The client's JWT is passed in the Authorization header and verified here.
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  );

  const { data: user, error: userError } = await supabaseClient.auth.getUser();

  if (userError || !user || !user.user) {
    console.error('Unauthorized request:', userError?.message || 'No user data');
    return new Response(
      JSON.stringify({ error: 'Unauthorized', details: userError?.message }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // 5. Get Wasabi credentials from Supabase Secrets
  const WASABI_ACCESS_KEY_ID = Deno.env.get('WASABI_ACCESS_KEY_ID');
  const WASABI_SECRET_ACCESS_KEY = Deno.env.get('WASABI_SECRET_ACCESS_KEY');
  const WASABI_REGION = Deno.env.get('WASABI_REGION');
  const WASABI_BUCKET_NAME = Deno.env.get('WASABI_BUCKET_NAME');

  if (
    !WASABI_ACCESS_KEY_ID ||
    !WASABI_SECRET_ACCESS_KEY ||
    !WASABI_REGION ||
    !WASABI_BUCKET_NAME
  ) {
    console.error('Server configuration error: Wasabi credentials missing.');
    return new Response(
      JSON.stringify({ error: 'Server configuration error: Wasabi credentials missing' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // 6. Construct a unique file key (path) in Wasabi
  const fileKey = `uploads/${user.user.id}/${Date.now()}_${filename}`;

  // 7. Initialize S3 client for Wasabi
  const s3Client = new S3Client({
    region: WASABI_REGION,
    credentials: {
      accessKeyId: WASABI_ACCESS_KEY_ID,
      secretAccessKey: WASABI_SECRET_ACCESS_KEY,
    },
    endpoint: `https://s3.${WASABI_REGION}.wasabisys.com`, // Wasabi S3 endpoint URL
  });

  let signedUrl: string;
  try {
    // 8. Generate the pre-signed URL for a PUT operation
    signedUrl = await getSignedUrl(
      s3Client,
      new PutObjectCommand({
        Bucket: WASABI_BUCKET_NAME,
        Key: fileKey,
        ContentType: contentType,
        ACL: 'public-read', // Set ACL for public read access after upload.
      }),
      { expiresIn: 300 } // URL valid for 5 minutes (300 seconds)
    );
  } catch (error) {
    console.error('Error generating signed URL:', error);
    return new Response(
      JSON.stringify({ error: 'Failed to generate signed URL', details: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // 9. Return the signed URL and the file key to the client
  return new Response(
    JSON.stringify({ signedUrl: signedUrl, fileKey: fileKey }),
    {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    }
  );
});