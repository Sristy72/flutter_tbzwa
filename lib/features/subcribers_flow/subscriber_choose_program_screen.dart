import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'choose_program_details_screen.dart';

class SubscriberChooseProgramScreen extends StatelessWidget {
  const SubscriberChooseProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Self Learning System',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Select the program that fits your goals',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildProgramCard(
              title: "START ZONE",
              subtitle: "Beginner",
              bullets: [
                "16 lessons + 8 quizzes + 16 Boost",
                "Audio & Video Recording",
              ],
              price: "€73.19",
              color: const Color(0xFF00A3DA),
            ),
            const SizedBox(height: 16),
            _buildProgramCard(
              title: "START ZONE+",
              subtitle: "Advanced Beginner",
              bullets: [
                "16 lessons + 8 quizzes",
                "16 Packs x 13 boost activities",
                "Audio & Video Recording",
              ],
              price: "€79.34",
              color: const Color(0xFFFC643B),
            ),
            const SizedBox(height: 16),
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
              color: const Color(0xFF00AA63),
            ),
            const SizedBox(height: 16),
            _buildProgramCard(
              title: "ELITE",
              subtitle: "Mastery",
              bullets: [
                "22 modules x 4 in-depth lessons",
                "Intensive speaking & Deep writing",
                "Critical thinking & Real-world use",
              ],
              price: "€99.89",
              color: const Color(0xFF6B66FF),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard({
    required String title,
    required String subtitle,
    required List<String> bullets,
    required String price,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => ChooseProgramDetailsScreen(title: title, color: color)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptText(
              title,
              const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Self Learning Program',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ...bullets.map((bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: CircleAvatar(radius: 2, backgroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bullet,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• Lifetime access',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Coming Soon",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              offset: const Offset(1, -8), // Superscript shift
              child: Text(
                '+',
                style: baseStyle.copyWith(
                  fontSize: baseStyle.fontSize! * 0.65,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
