import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionsHistoryScreen extends StatelessWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {'type': 'Top Up', 'name': 'Kathy Onana', 'time': 'Just Now', 'amount': '\$200.00', 'icon': Icons.north_east, 'color': Color(0xFF5151EF), 'bgColor': Color(0xFFEBEBFF)},
      {'type': 'Buy Plan', 'name': 'Kathy Onana', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.shopping_cart_outlined, 'color': Color(0xFF26A69A), 'bgColor': Color(0xFFDFF2F4)},
      {'type': 'Send Gift', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.card_giftcard_outlined, 'color': Color(0xFFEC4899), 'bgColor': Color(0xFFFCE7F3)},
      {'type': 'Referral', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.share_outlined, 'color': Color(0xFFF59E0B), 'bgColor': Color(0xFFFEF3C7)},
      {'type': 'Top Up', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$200.00', 'icon': Icons.north_east, 'color': Color(0xFF5151EF), 'bgColor': Color(0xFFEBEBFF)},
      {'type': 'Buy Plan', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.shopping_cart_outlined, 'color': Color(0xFF26A69A), 'bgColor': Color(0xFFDFF2F4)},
      {'type': 'Send Gift', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.card_giftcard_outlined, 'color': Color(0xFFEC4899), 'bgColor': Color(0xFFFCE7F3)},
      {'type': 'Referral', 'name': 'Marie Claire', 'time': 'Just Now', 'amount': '\$20.00', 'icon': Icons.share_outlined, 'color': Color(0xFFF59E0B), 'bgColor': Color(0xFFFEF3C7)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B7280), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Transactions History",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tx['bgColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tx['icon'], color: tx['color'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['type'],
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${tx['name']} • ${tx['time']}",
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  tx['amount'],
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
