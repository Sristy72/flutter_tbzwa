import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kathy Onana • Just Now",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$${transaction.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.title) {
      case "Top Up": return Icons.upload_outlined;
      case "Buy Plan": return Icons.shopping_cart_outlined;
      case "Send Gift": return Icons.card_giftcard_outlined;
      case "Referral": return Icons.share_outlined;
      default: return Icons.payment_outlined;
    }
  }

  Color _getIconColor() {
    switch (transaction.title) {
      case "Top Up": return const Color(0xFF5151EF);
      case "Buy Plan": return const Color(0xFF26A69A);
      case "Send Gift": return const Color(0xFFEC4899);
      case "Referral": return const Color(0xFFF97316);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getIconBackground() {
    return _getIconColor().withOpacity(0.1);
  }
}
