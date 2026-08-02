import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'keys_to_success_screen.dart';

class WelcomeSuccessScreen extends StatelessWidget {
  const WelcomeSuccessScreen({super.key});

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
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 16,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),

                        // Top Segmented Progress Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Active Step Pill
                            Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5151EF),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Inactive Step Pill 2
                            Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Inactive Step Pill 3
                            Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Logo Section
                        Center(
                          child: Image.asset(
                            'assets/images/mainLogo.png',
                            height: 72,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Elegant backup vector drawing if asset fails
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(5, (index) {
                                      final heights = [30, 24, 32, 22, 28];
                                      return Container(
                                        width: 8,
                                        height: heights[index].toDouble(),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF818CF8),
                                              Color(0xFF4F46E5),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Talk /'BZ/",
                                    style: TextStyle(
                                      color: Color(0xFF5151EF),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const Text(
                                    "Parle, retiens, accapare",
                                    style: TextStyle(
                                      color: Color(0xFF818CF8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 106),

                        // Title Text
                        const Text(
                          "Welcome to Talk /'BZ/!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF191C1F),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            // letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 21),

                        // Subtitle text
                        const Text(
                          "We're excited to have you on board.\nLet's get ready for success!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF191C1F),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 86),

                    // Next Button at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 12, right: 24, left: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const KeysToSuccessScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5151EF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Next!",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
