import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'subscriber_choose_program_screen.dart';
import 'upgrade_plan_screen.dart';

class SubcriberLearnScreen extends StatefulWidget {
  const SubcriberLearnScreen({super.key});

  @override
  State<SubcriberLearnScreen> createState() => _SubcriberLearnScreenState();
}

class _SubcriberLearnScreenState extends State<SubcriberLearnScreen> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Main Content (Blurred) ──────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // ─── Header row with menu icon ──────────────────────────────
                  Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(
                            Icons.menu,
                            color: Color(0xFF1E293B),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCurrentLevelCard(),

                  const SizedBox(height: 30),
                  const Text(
                    "Choose Your Level",
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLevelGrid(),
                  const SizedBox(height: 40),
                  _buildClassesSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // ─── Blur Overlay ──────────────────────────────────────────────────
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: GestureDetector(
                  onTap: () =>
                      Get.to(() => const SubscriberChooseProgramScreen()),
                  child: Container(color: Colors.black.withOpacity(0.01)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE9E9E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Current Level",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Level 3 - Intermediate",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text("🏆", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Get.to(() => const UpgradePlanScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A82E7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Upgrade",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.215,
      children: [
        _buildLevelCard(
          "START ZONE",
          "Beginner",
          "Start your English journey with confidence",
          [const Color(0xFF00A3DA), const Color(0xFF00BCEE)],
        ),
        _buildLevelCard(
          "START ZONE+",
          "Advanced Beginner",
          "Build solid basics and gain momentum",
          [const Color(0xFFFC643B), const Color(0xFFFE9A7B)],
        ),
        _buildLevelCard(
          "FLUENCY+ P1",
          "Foundation",
          "Lay the groundwork for real communication",
          [const Color(0xFFD31E51), const Color(0xFFFE6E61)],
        ),
        _buildLevelCard(
          "FLUENCY+ P2",
          "Breakthrough",
          "Start expressing your ideas with clarity",
          [const Color(0xFF0089FF), const Color(0xFF02E5FA)],
        ),
        _buildLevelCard(
          "FLUENCY+ P3",
          "Elevation",
          "Reach a more natural and confident fluency",
          [const Color(0xFF00BA7C), const Color(0xFF00BC7D)],
        ),
        _buildLevelCard(
          "ELITE",
          "Mastery",
          "Speak with precision, power, and confidence",
          [const Color(0xFF5D5DFF), const Color(0xFF8B8BFF)],
        ),
      ],
    );
  }

  Widget _buildLevelCard(
    String title,
    String subtitle,
    String desc,
    List<Color> colors,
  ) {
    return GestureDetector(
      onTap: () => Get.to(() => const SubscriberChooseProgramScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEDF1)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubscriptText(
                    title,
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Level 2 Classes",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Unlimited Access",
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(child: _buildTabButton("Upcoming", 0)),
              Expanded(child: _buildTabButton("Completed", 1)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildClassCard(),
        const SizedBox(height: 16),
        _buildClassCard(),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF000000)
                : const Color(0xFF000000),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=james',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Everyday Conversations",
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "James Anderson",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildClassInfoItem(Icons.calendar_today_outlined, "2026-03-30"),
              const SizedBox(width: 16),
              _buildClassInfoItem(Icons.access_time_outlined, "19:30"),
              const Spacer(),
              _buildClassInfoItem(Icons.people_outline, "18/20"),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Practice common daily conversations and improve your fluency.",
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5456E7)),
                ),
                child: const Text(
                  "60 min",
                  style: TextStyle(
                    color: Color(0xFF5456E7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFCBD5E1),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptText(String text, TextStyle baseStyle) {
    if (!text.contains('+')) {
      return Text(text, style: baseStyle);
    }

    List<InlineSpan> spans = [];
    final parts = text.split('+');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }

      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: const Offset(1, -6), // Superscript shift
              child: Text(
                '+',
                style: baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.65),
              ),
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans));
  }
}
