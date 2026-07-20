import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'track_invites_screen.dart';
import '../../community/screens/community_messages_screen.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Handshake Illustration
              Center(
                child: Image.asset('assets/images/refferal.png', width: 208, height: 116,),
              ),
              const SizedBox(height: 48),
              // Headline
              const Text(
                "INVITE YOUR FRIENDS & EARN\n10,000 EURO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              // Instruction List
              _buildInstructionItem(
                icon: Icons.share_outlined,
                title: "Share your code",
                subtitle: "Share your unique referral code to your friends and family.",
              ),
              const SizedBox(height: 24),
              _buildInstructionItem(
                icon: Icons.pan_tool_outlined,
                title: "Earn referral bonus",
                subtitle: "Receive a 10,00 EUR bonus when a person you referred verifies their account and enrolls in the program using your referral code.",
              ),
              const SizedBox(height: 40),
              // Referral Code Card
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5151EF), Color(0xFF7B51EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your referral code",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "DSDFGSG424",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: "DSDFGSG424"));
                          Get.snackbar(
                            "Copied!",
                            "Referral code copied to clipboard",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: Colors.black,
                            margin: const EdgeInsets.all(20),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                        child: const Text("Copy"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Invite Friends Button
              ElevatedButton(
                onPressed: () => Get.to(() => const CommunityMessagesScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B167),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Invite friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // T&C link
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  children: [
                    TextSpan(text: "By clicking invite friends, you agree to our\n"),
                    TextSpan(
                      text: "term & conditions.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Total Earnings Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "YOUR TOTAL EARNINGS",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildEarningStat("0", "REFERRALS"),
                          ),
                          Container(height: 40, width: 1, color: const Color(0xFFE5E7EB)),
                          Expanded(
                            child: _buildEarningStat("10,00 EUR", "TOTAL EARNED"),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    ListTile(
                      onTap: () => Get.to(() => const TrackInvitesScreen()),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: const Text(
                        "Track your invites",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00B167),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1F2937)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF1F2937)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
