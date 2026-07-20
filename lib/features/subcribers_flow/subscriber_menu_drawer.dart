import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/auth_controller.dart';
import '../bz_pad/screens/bz_pad_splash_screen.dart';
import '../bz_wallet/screens/bz_wallet_splash_screen.dart';
import '../daily_mission/screens/daily_mission_splash_screen.dart';
import '../library/screens/library_splash_screen.dart';
import '../bz_wallet/widgets/send_gift_sheet.dart';
import '../profile/screens/referral_screen.dart';

class SubscriberMenuDrawer extends StatelessWidget {
  const SubscriberMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFF2F3F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Menu Items ───────────────────────────────────────────────────
            _buildMenuItem(
              context,
              icon: Icons.account_balance_wallet_outlined,
              label: "BZ-Wallet",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const BZWalletSplashScreen());
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.note_alt_outlined,
              label: "BZ-Pad",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const BZPadSplashScreen());
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.library_books_outlined,
              label: "BZ-Library",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => LibrarySplashScreen());
              } 
            ),
            _buildMenuItem(
              context,
              icon: Icons.task_alt_outlined,
              label: "BZ-Daily Mission",
              onTap: () {
                Navigator.pop(context);
                DailyMissionSplashScreen();
              }
            ),
            _buildMenuItem(
              context,
              icon: Icons.card_giftcard_outlined,
              label: "Reward/Gifts",
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SendGiftSheet(),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.reply_outlined,
              label: "Referral",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ReferralScreen());
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            // ─── Logout ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              child: ListTile(
                onTap: () {
                  Navigator.pop(context);
                  // Logout logic
                },
                leading: const Icon(
                  Icons.logout_outlined,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF374151),
          size: 22,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: const Color(0xFFF3F4F6),
        splashColor: const Color(0xFFE5E7EB),
      ),
    );
  }
}
