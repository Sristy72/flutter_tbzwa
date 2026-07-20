import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/button_widgets.dart';
import '../controller/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    final List<Map<String, String>> onboardingData = [
      {
        "image": "assets/images/logo.png",
        "title": "Learn English your way",
        "subtitle": "Self-learning or live classes with real teachers",
      },
      {
        "image": "assets/images/letter.png",
        "title": "Daily Practice Made Simple",
        "subtitle": "Record, watch, and write — just 14 min/day",
      },
      {
        "image": "assets/images/chat.png",
        "title": "Join The Community",
        "subtitle": "Chat, Share and Learn Together",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Background Image
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/images/Onboarding_bg.png',
          //     fit: BoxFit.cover,
          //   ),
          // ),

          /// Dark Overlay (optional)
          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(0.15),
          //   ),
          // ),

          /// PageView
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              final bool textAboveImage = index == 1;
              final bool showCenterAnimation = index == 2;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    /// Top Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Back Button
                        Obx(
                          () => controller.currentPageIndex.value == 0
                              ? const SizedBox(width: 40)
                              : IconButton(
                                  onPressed: controller.previousPage,
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                        ),

                        /// Skip Button
                        TextButton(
                          onPressed: controller.skipPage,
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color(0xFF000055),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // const Spacer(),
                    const SizedBox(height: 38),

                    if (textAboveImage) ...[
                      /// Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item["title"]!,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5151EF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Subtitle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item["subtitle"]!,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000055),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 38),

                      /// Center Image
                      Image.asset(item["image"]!, height: 280),
                    ] else ...[
                      /// Center Image
                      Image.asset(item["image"]!, height: 280),

                      const SizedBox(height: 38),

                      /// Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item["title"]!,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5151EF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Subtitle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item["subtitle"]!,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000055),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),

                      if (showCenterAnimation) ...[
                        // const SizedBox(height: 24),
                        // Center(
                        //   child: AnimatedContainer(
                        //     duration: const Duration(milliseconds: 300),
                        //     width: 8,
                        //     height: 8,
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFF5151EF),
                        //       borderRadius: BorderRadius.circular(32),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 151),

                        // Show dots (including inactive) on the last page as well
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(onboardingData.length, (
                              dotIndex,
                            ) {
                              final bool isActive =
                                  controller.currentPageIndex.value == dotIndex;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 0),
                                margin: const EdgeInsets.only(right: 8),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF5151EF)
                                      : const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 90),

                        Center(
                          child: PrimaryButton(
                            width: 358,
                            // height: 48,
                            text: 'Get Started',
                            onSimplePressed: controller.nextPage,
                          ),
                        ),
                      ],
                    ],

                    if (!showCenterAnimation) const Spacer(),

                    if (!showCenterAnimation)
                      /// Bottom Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Dot Indicator
                          Obx(
                            () => Row(
                              children: List.generate(onboardingData.length, (
                                dotIndex,
                              ) {
                                bool isActive =
                                    controller.currentPageIndex.value ==
                                    dotIndex;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 0),
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF5151EF)
                                        : const Color(0xFFEAEAEA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              }),
                            ),
                          ),

                          /// Next Button
                          /// Next Button with One Third Circle Background
                          /// Next Button with Corner Circle
                          GestureDetector(
                            onTap: controller.nextPage,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  /// Big Circle at Bottom Right Corner
                                  Positioned(
                                    bottom: -85,
                                    right: -75,
                                    child: Container(
                                      height: 170,
                                      width: 170,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5151EF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                  /// Arrow Icon
                                  const Positioned(
                                    bottom: 10,
                                    right: 15,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
