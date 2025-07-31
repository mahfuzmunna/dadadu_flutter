import 'package:dart_ipify/dart_ipify.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Checks for a deferred deep link by matching the device's IP address.
/// Returns the referrer's user ID if a match is found, otherwise null.
Future<String?> checkForDeferredReferral() async {
  try {
    // 1. Get the device's public IP address.
    final ip = await Ipify.ipv4();
    final supabase = Supabase.instance.client;

    // 2. Query the referral_clicks table for a recent match.
    // We look for a click from the same IP within the last 30 minutes.
    final response = await supabase
        .from('referral_clicks')
        .select('referral_id')
        .eq('ip_address', ip)
        .gte(
            'created_at',
            DateTime.now()
                .subtract(const Duration(minutes: 30))
                .toIso8601String())
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null && response.isNotEmpty) {
      final referralId = response['referral_id'] as String;
      print('✅ Deferred referral link successful! Referred by: $referralId');
      return referralId;
    }
  } catch (e) {
    print('Error checking for deferred referral: $e');
  }

  print('No deferred referral link found.');
  return null;
}
