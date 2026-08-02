import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'fluency_plus_screen.dart';

class SelfLearningSystemScreen extends StatelessWidget {
  const SelfLearningSystemScreen({super.key});

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
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Self Learning System",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select the program that fits your goals",
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              /// Card 1: START ZONE (Beginner)
              _buildProgramCard(
                title: "START ZONE",
                subtitle: "Beginner",
                bullets: [
                  "16 lessons + 8 quizzes + 16 Boost",
                  "Audio & Video Recording",
                ],
                price: "€73.19",
                cardColor: const Color(0xFF0186B3),
                buttonBgColor: const Color(0xFFEEEEFD),
                buttonTextColor: const Color(0xFF0186B3),
                bordercolor: const Color(0xFF02A5DD),
              ),
              const SizedBox(height: 32),

              /// Card 2: START ZONE* (Advanced Beginner)
              _buildProgramCard(
                title: "START ZONE*",
                subtitle: "Advanced Beginner",
                bullets: [
                  "16 lessons + 8 quizzes",
                  "16 Packs x 13 boost activities",
                  "Audio & Video Recording",
                ],
                price: "€79.34",
                cardColor: const Color(0xFFFA8F45),
                buttonBgColor: const Color(0xFFFEF1E8),
                buttonTextColor: const Color(0xFFF97316),
                bordercolor: const Color(0xFFFA8F45),
              ),
              const SizedBox(height: 32),

              /// Card 3: FLUENCY+ (Autonomy)
              _buildProgramCard(
                title: "FLUENCY+",
                subtitle: "Autonomy",
                bullets: [
                  "48 packs x 2 in-depth lessons",
                  "24 Discussion Topics",
                  "24 Discussion-Based Quizzes",
                  "Audio & Video Recording",
                ],
                price: "€128.54",
                cardColor: const Color(0xFF0A9A50),
                buttonBgColor: const Color(0xFFE9F9EF),
                buttonTextColor: const Color(0xFF06783D),
                bordercolor: const Color(0xFF0A9A50),
                onTap: () => Get.to(() => const FluencyPlusScreen()),
              ),
              const SizedBox(height: 32),

              /// Card 4: ELITE (Mastery)
              _buildProgramCard(
                title: "ELITE",
                subtitle: "Mastery",
                bullets: [
                  "22 modules x 4 in-depth lessons",
                  "Intensive speaking & Deep writing",
                  "Critical thinking & Real-world use",
                ],
                price: "€99.89",
                cardColor: const Color(0xFF6060FD),
                buttonBgColor: const Color(0xFFFFFFFF),
                buttonTextColor: const Color(0xFF5151EF),
                bordercolor: const Color(0xFF6060FD),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCard({
    required String title,
    required String subtitle,
    required List<String> bullets,
    required String price,
    required Color cardColor,
    required Color buttonBgColor,
    required Color buttonTextColor,
    required Color bordercolor,
    VoidCallback? onTap,
  }) {
    final cardBorderColor = cardColor == bordercolor
        ? Colors.white.withOpacity(0.30)
        : bordercolor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cardBorderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: cardColor.withAlpha(51), // 20% opacity
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                // letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                color: Color(0xFFFFFFFF), // 85% opacity
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: cardColor == bordercolor
                  ? Colors.white.withOpacity(0.35)
                  : bordercolor,
              thickness: 1.2,
            ),
            const SizedBox(height: 20),
            // Bullet points
            ...bullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• ",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: TextStyle(
                          color: Color(0xFFFFFFFF), // 90% opacity
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Bottom area: Price and "Coming Soon" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "• Lifetime access",
                          style: TextStyle(
                            color: Color(0xFFFFFFFF), // 85% opacity
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.only(
                    top: 12,
                    right: 24,
                    bottom: 12,
                    left: 24,
                  ),
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Coming Soon",
                    style: TextStyle(
                      color: buttonTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
