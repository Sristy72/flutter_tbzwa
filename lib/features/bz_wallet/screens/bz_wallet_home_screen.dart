import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bz_wallet_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_action_item.dart';
import '../widgets/transaction_item.dart';
import '../widgets/send_gift_sheet.dart';
import 'top_up_screen.dart';
import 'transactions_history_screen.dart';

class BZWalletHomeScreen extends StatelessWidget {
  const BZWalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BZWalletController());

    return Scaffold(
      backgroundColor: Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () => Get.back(),
                  ),

                  Expanded(child: _buildHeader()),
                ],
              ),

              const SizedBox(height: 30),
              const BalanceCard(),
              const SizedBox(height: 30),
              _buildQuickActions(context),
              const SizedBox(height: 30),
              _buildUpcomingSection(controller),
              const SizedBox(height: 30),
              _buildTransactionHistoryHeader(),
              const SizedBox(height: 16),
              Obx(() => _buildTransactionsList(controller)),
              const SizedBox(height: 20),
              _buildDisclaimerCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning,",
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            Text(
              "Kathy Onana",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEBECEE)),
          ),
          child: const Badge(
            smallSize: 8,
            backgroundColor: Colors.red,
            child: Icon(Icons.notifications_none_outlined, color: Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuickActionItem(
          icon: Icons.add,
          label: "Top Up",
          color: const Color(0xFF5151EF),
          onTap: () => Get.to(() => const TopUpScreen()),
        ),
        QuickActionItem(
          icon: Icons.shopping_cart_outlined,
          label: "Buy Plan",
          color: const Color(0xFF26A69A),
          onTap: () {},
        ),
        QuickActionItem(
          icon: Icons.card_giftcard_outlined,
          label: "Send Gift",
          color: const Color(0xFFEC4899),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const SendGiftSheet(),
            );
          },
        ),
        QuickActionItem(
          icon: Icons.history_outlined,
          label: "History",
          color: const Color(0xFF6B7280),
          onTap: () => Get.to(() => const TransactionsHistoryScreen()),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(BZWalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Upcoming",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEAEDF1)),
          ),
          child: Column(
            children: [
              _buildUpcomingRow("Immersion++ 3 Months", "\$100"),
              const SizedBox(height: 12),
              _buildUpcomingRow("Wallet Applied", "-\$65"),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEAEDF1)),
              const SizedBox(height: 12),
              _buildUpcomingRow("Final Payment", "\$35", isBold: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5151EF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Pay \$35.00", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF374151),
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1F2937),
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BZWalletController controller) {
    if (controller.transactions.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return TransactionItem(
          transaction: controller.transactions[index],
          onTap: () {},
        );
      },
    );
  }


  Widget _buildReferralCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline, color: Color(0xFF22C55E)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Earn \$10 when you refer your friends.",
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCDCFC),
              foregroundColor: const Color(0xFF5151EF),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Invite friends", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Color(0xFFEAB308), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Wallet funds cannot be withdrawn. They are used to reduce future subscription payments.",
              style: TextStyle(
                color: Color(0xFF713F12),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Transactions History",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => Get.to(() => const TransactionsHistoryScreen()),
          child: const Text(
            "View All",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Transactions Found",
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your wallet is empty. Top up to purchase programs easily.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
