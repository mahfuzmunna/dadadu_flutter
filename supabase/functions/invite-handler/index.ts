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
      const supabase = createClient(
        Deno.env.get('https://sqdqbmnqosfzhmrpbvqe.supabase.co')!,
        Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNxZHFibW5xb3NmemhtcnBidnFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0NDUyODQsImV4cCI6MjA2ODAyMTI4NH0.O4SHLpBxaxKTXjyPiysYR4I57JXPS5LaBaktEbOY5IE')!
      );
      // Get device info from request headers
      const ipAddress = req.headers.get('x-forwarded-for')?.split(',').shift();
      const userAgent = req.headers.get('user-agent');

      await supabase.from('referral_clicks').insert({
        referral_id: referredById,
        ip_address: ipAddress,
        user_agent: userAgent,
      });
    } catch (e) { console.error('Error logging referral click:', e); }
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