// supabase/functions/invite-handler/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const referredById = url.searchParams.get('referred_by');
  const appStoreUrl = 'https://apps.apple.com/app/your-app-id';
  const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.dadadu.app';

  // 1. Log the click for fingerprinting
  if (referredById) {
    try {
      // ✅ FIX: Assert that env variables exist and create the client
      const supabaseClient = createClient(
        Deno.env.get('DADADU_SUPABASE_URL')!,
        Deno.env.get('DADADU_SUPABASE_ANON_KEY')!,
        {
          global: {
            // Pass auth headers to the client for RLS
            headers: { Authorization: req.headers.get('Authorization')! },
          },
        }
      );

      // Get device info from request headers
      const ipAddress = req.headers.get('x-forwarded-for')?.split(',').shift();
      const userAgent = req.headers.get('user-agent');

      // ✅ FIX: Use the correct client variable name
      await supabaseClient.from('referral_clicks').insert({
        referral_id: referredById,
        ip_address: ipAddress,
        user_agent: userAgent,
      });
    } catch (e) {
      console.error('Error logging referral click:', e);
    }
  }

  // 2. Redirect to the appropriate app store
  const userAgent = req.headers.get('user-agent') || '';
  if (/android/i.test(userAgent)) {
    return Response.redirect(playStoreUrl, 302);
  } else if (/iPad|iPhone|iPod/.test(userAgent)) {
    return Response.redirect(appStoreUrl, 302);
  } else {
    // Fallback for desktop browsers
    return Response.redirect('https://brosisus.com', 302);
  }
});
