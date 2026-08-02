import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/screens/login_screen.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update indicator
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  // Next Page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      Get.offAll(() => const LoginScreen());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Previous Page
  void previousPage() {
    if (currentPageIndex.value != 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip
  void skipPage() {
    Get.offAll(() => const LoginScreen());
  }
}