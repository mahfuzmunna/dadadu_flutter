// supabase/functions/record-post-asset/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method Not Allowed' }),
      { status: 405, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const { postId, fileKey, assetType } = await req.json(); // assetType: 'video' or 'thumbnail'

  if (!postId || !fileKey || !assetType) {
    return new Response(
      JSON.stringify({ error: 'Missing postId, fileKey, or assetType' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        // IMPORTANT: Use the Authorization header from the client request
        // This ensures the function knows which user is making the request
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  );

  // Authenticate and authorize the user
  const { data: user, error: userError } = await supabaseClient.auth.getUser();

  if (userError || !user || !user.user) {
    console.error('Unauthorized request:', userError?.message || 'No user');
    return new Response(
      JSON.stringify({ error: 'Unauthorized', details: userError?.message }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // Get Bunny CDN hostname from Supabase Secrets
  const BUNNY_CDN_HOSTNAME = Deno.env.get('BUNNY_CDN_HOSTNAME');
  if (!BUNNY_CDN_HOSTNAME) {
    console.error('Server configuration error: Bunny CDN hostname missing.');
    return new Response(
      JSON.stringify({ error: 'Server configuration error: Bunny CDN hostname missing' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // Construct the full Bunny CDN URL
  const cdnUrl = `https://${BUNNY_CDN_HOSTNAME}/${fileKey}`; // This is the URL your app will use to fetch the asset

  let updateData: { video_url?: string; thumbnail_url?: string } = {}; // Use snake_case for DB columns
  if (assetType === 'video') {
    updateData = { video_url: cdnUrl };
  } else if (assetType === 'thumbnail') {
    updateData = { thumbnail_url: cdnUrl };
  } else {
    return new Response(
      JSON.stringify({ error: 'Invalid asset type. Must be "video" or "thumbnail".' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  // Update the post in the database.
  // Use .update() instead of .insert() if the post already exists from a previous step,
  // or use .upsert() if you want to insert if not exists, update if exists.
  // We're assuming the post ID is passed and you're updating an existing post draft.
  const { data, error: dbError } = await supabaseClient
    .from('posts') // Ensure your table name is 'posts'
    .update(updateData)
    .eq('id', postId)
    .eq('user_id', user.user.id) // IMPORTANT: Ensure only the owner can update their post
    .select(); // Select the updated row to return it

  if (dbError) {
    console.error('Error updating post with asset URL:', dbError);
    return new Response(
      JSON.stringify({ error: 'Failed to record asset URL', details: dbError.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }

  if (!data || data.length === 0) {
    console.warn(`Post with ID ${postId} not found or user ${user.user.id} unauthorized to update.`);
    return new Response(
      JSON.stringify({ error: 'Post not found or unauthorized to update.' }),
      { status: 404, headers: { 'Content-Type': 'application/json' } }
    );
  }

  return new Response(
    JSON.stringify({ message: 'Asset URL recorded successfully', cdnUrl: cdnUrl, updatedPost: data[0] }),
    {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    }
  );
});