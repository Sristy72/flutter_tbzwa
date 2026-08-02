import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bz_wallet_controller.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BZWalletController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5151EF), Color(0xFF4242D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "BZ-Wallet Balance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildCurrencySwitcher(controller),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.formattedBalance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "User ID: ${controller.userId}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.copy, color: Colors.white, size: 14),
                ],
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySwitcher(BZWalletController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ["USD", "EUR", "FCFA"].map((currency) {
          return Obx(() {
            final isSelected = controller.selectedCurrency.value == currency;
            return GestureDetector(
              onTap: () => controller.changeCurrency(currency),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currency,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF5151EF) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

