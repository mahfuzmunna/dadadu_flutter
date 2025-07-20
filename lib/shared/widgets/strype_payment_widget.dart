import 'package:flutter/material.dart';
import '../../services/stripe_service.dart';

class StripePaymentWidget extends StatefulWidget {
  final String badgeId;
  final String badgeLabel;
  final double price;
  final String sellerId;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const StripePaymentWidget({
    super.key,
    required this.badgeId,
    required this.badgeLabel,
    required this.price,
    required this.sellerId,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<StripePaymentWidget> createState() => _StripePaymentWidgetState();
}

class _StripePaymentWidgetState extends State<StripePaymentWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final commission = StripeService.calculateCommission(widget.price);
    final sellerAmount = StripeService.getSellerAmount(widget.price);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payment, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Paiement sécurisé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Badge info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              children: [
                Text(
                  widget.badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prix: \$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Détails de facturation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildPriceRow('Prix badge', widget.price),
                _buildPriceRow('Commission Dadadu (5%)', commission, isCommission: true),
                const Divider(color: Colors.grey),
                _buildPriceRow('Total à payer', widget.price, isTotal: true),
                const SizedBox(height: 8),
                Text(
                  'Le vendeur recevra \$${sellerAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton paiement
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _processPayment,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.credit_card),
              label: Text(
                _isLoading ? 'Traitement...' : 'Payer \$${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: Colors.green.withValues(alpha: 0.3),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sécurité info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'Paiement sécurisé par Stripe',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isCommission = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey[300],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isCommission ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isCommission ? Colors.red[300] : isTotal ? Colors.amber : Colors.white,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      // 1. Créer Payment Intent
      final paymentIntent = await StripeService.createPaymentIntent(
        amount: widget.price,
        currency: 'usd',
        badgeId: widget.badgeId,
        sellerId: widget.sellerId,
      );

      // 2. Traiter le paiement
      final success = await StripeService.processPayment(
        clientSecret: paymentIntent['client_secret'] as String,
        badgeId: widget.badgeId,
      );

      if (success) {
        widget.onSuccess();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Badge acheté avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Paiement échoué');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}