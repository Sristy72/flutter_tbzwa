import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'payment_method_screen.dart';

class ImmersionPlansScreen extends StatefulWidget {
  const ImmersionPlansScreen({super.key});

  @override
  State<ImmersionPlansScreen> createState() => _ImmersionPlansScreenState();
}

class _ImmersionPlansScreenState extends State<ImmersionPlansScreen> {
  // Currently selected subscription duration (default to 9 months, index 2)
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _durations = [
    {"duration": "3 months", "price": "€45/mo", "badge": null},
    {"duration": "6 months", "price": "€35/mo", "badge": null},
    {"duration": "9 months", "price": "€30/mo", "badge": null},
    {"duration": "12 months", "price": "€25/mo", "badge": "BEST VALUE"},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF263451),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            children: [
              const TextSpan(text: "IMMERSION"),
              WidgetSpan(
                child: Transform.translate(
                  offset: const Offset(0, -8),
                  child: const Text(
                    "++",
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// What's Included Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What’s included",
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBulletPoint("24/7 English Practice"),
                    _buildBulletPoint("24/7 Access to Teachers"),
                    _buildBulletPoint("Live Zoom Classes"),
                    _buildBulletPoint("Live Sessions & Clubs"),
                    _buildBulletPoint("Voice Rooms"),
                    _buildBulletPoint("Global Network"),
                    _buildBulletPoint("Group Chat"),
                    _buildBulletPoint("Smart Progress Tracking"),
                    _buildBulletPoint("Immersive Experience"),
                    _buildBulletPoint("Premium Benefits"),
                    _buildBulletPoint("7 Day Refund Policy"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              /// Subtitle
              const Text(
                "Choose Your Subscription Duration",
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              /// Duration Packages Grid (2x2)
              Row(
                children: [
                  Expanded(child: _buildGridCard(0)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGridCard(1)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildGridCard(2)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGridCard(3)),
                ],
              ),
              const SizedBox(height: 16),

              /// Lifetime Access Card
              _buildLifetimeCard(4),
              const SizedBox(height: 20),

              /// Refund Policy Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "7 Day Refund Policy",
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Not satisfied? Request a refund within 7 days of subscribing. Admin reviews manually.",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 1.20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// Continue Payment Button
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const PaymentMethodScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5151EF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue Payment",
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(int index) {
    final item = _durations[index];
    final isSelected = _selectedIndex == index;
    final badgeText = item["badge"];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF5F4FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF5151EF) : const Color(0xFF94A3B8).withOpacity(0.20),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["duration"],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF5151EF) : const Color(0xFF374151),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["price"],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF5151EF).withAlpha(180) : const Color(0xFF94A3B8),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: 0,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5151EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  // letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLifetimeCard(int index) {
    final isSelected = _selectedIndex == index;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF5F4FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF5151EF) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Lifetime Access",
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF5151EF) : const Color(0xFF374151),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "€30",
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF5151EF).withAlpha(180) : const Color(0xFF94A3B8),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5151EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              "BEST DEAL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                // letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
