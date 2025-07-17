import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final String projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

class StripeService {
  /// Create Payment Intent via Firebase Cloud Function
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String badgeId,
    required String sellerId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final functionUrl =
        'https://us-central1-$projectId.cloudfunctions.net/createPaymentIntent';

    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': (amount * 100).toInt(),
        'currency': currency,
        'badgeId': badgeId,
        'sellerId': sellerId,
        'buyerId': currentUserId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Stripe Function Error: ${response.body}');
    }
  }

  /// Confirm payment client side with Stripe SDK
  static Future<bool> processPayment({
    required String clientSecret,
    required String badgeId,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      final paymentIntent = await _getPaymentIntentStatus(clientSecret);

      if (paymentIntent['status'] == 'succeeded') {
        await _finalizeBadgeTransaction(badgeId);
        return true;
      } else {
        throw Exception('Payment not confirmed');
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      return false;
    }
  }

  /// Fetch payment intent status from your backend (you may want to move this to backend)
  static Future<Map<String, dynamic>> _getPaymentIntentStatus(String clientSecret) async {
    // Usually this would call your backend or Stripe API with secret key,
    // but it's not recommended to expose secret key in Flutter app.
    throw UnimplementedError('Fetch payment status on server side, not client.');
  }

  /// Mark badge as sold and create transaction record in Firestore
  static Future<void> _finalizeBadgeTransaction(String badgeId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final badgeRef = FirebaseFirestore.instance.collection('marketplace_badges').doc(badgeId);

      final badgeDoc = await transaction.get(badgeRef);

      if (!badgeDoc.exists) {
        throw Exception('Badge not found');
      }

      final badgeData = badgeDoc.data()!;
      final sellerId = badgeData['sellerId'] as String;
      final price = badgeData['price'] as num;

      transaction.update(badgeRef, {
        'status': 'sold',
        'buyerId': currentUserId,
        'soldAt': FieldValue.serverTimestamp(),
        'paymentMethod': 'stripe',
      });

      transaction.set(
        FirebaseFirestore.instance.collection('transactions').doc(),
        {
          'type': 'badge_purchase',
          'badgeId': badgeId,
          'sellerId': sellerId,
          'buyerId': currentUserId,
          'amount': price,
          'currency': 'USD',
          'timestamp': FieldValue.serverTimestamp(),
          'paymentMethod': 'stripe',
        },
      );
    });
  }

  /// Calculate 5% commission on amount
  static double calculateCommission(double amount) => amount * 0.05;

  /// Amount seller receives after commission deduction
  static double getSellerAmount(double amount) => amount - calculateCommission(amount);
}
