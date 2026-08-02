import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'upgrade_plan_screen.dart';

class ChooseProgramDetailsScreen extends StatelessWidget {
  final String title;
  final Color color;

  const ChooseProgramDetailsScreen({
    super.key,
    required this.title,
    required this.color,
  });

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
        title: _buildSubscriptText(
          title,
          const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildDetailCard(
              subTitle: "${title} P1",
              status: "Coming soon",
              color: color,
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              subTitle: "${title} P2",
              status: "Coming soon",
              color: color,
            ),
            const SizedBox(height: 20),
            _buildDetailCard(
              subTitle: "${title} P3",
              status: "Coming soon",
              color: color,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String subTitle,
    required String status,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => const UpgradePlanScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubscriptText(
                        subTitle,
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.lock_outline, color: Colors.white70, size: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Coming Soon",
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Coming Soon",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
              offset: const Offset(1, -6), // Superscript shift
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
