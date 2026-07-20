import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tbzwa/navbar_menu.dart' as subscriber_navigation;
import 'package:flutter_tbzwa/navigation_menu.dart' as learner_navigation;

import '../../../core/services/auth_storage_service.dart';
import '../../instructor/controllers/instructor_home_controller.dart';
import '../../navigation/instructor_nav_menu.dart' as instructor_navigation;
import '../../payment/screens/buy_plan_screen.dart';
import '../repositories/auth_repository.dart';

class RoleSelectionController extends GetxController {
  static const _selectableBackendRoles = {'learner', 'instructor'};

  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final AuthStorageService _authStorageService = AuthStorageService();

  // Selection State
  // Defaults to "learner" as seen highlighted in the user's design image
  final selectedRole = "learner".obs;
  final isSubmitting = false.obs;

  void selectRole(String role) {
    if (isSubmitting.value) return;
    selectedRole.value = role;
  }

  Future<void> proceed() async {
    if (isSubmitting.value) return;

    final requestedRole = selectedRole.value.trim().toLowerCase();
    if (!_selectableBackendRoles.contains(requestedRole)) {
      Get.snackbar(
        "Role Selection Failed",
        "Please choose a valid role to continue.",
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _authRepo.selectRole(requestedRole);

      await result.fold<Future<void>>(
        (fail) async {
          Get.snackbar(
            "Role Selection Failed",
            fail.message,
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
          );
        },
        (success) async {
          final data = success.data;
          final confirmedRole = data.user.role.trim().toLowerCase();

          if (confirmedRole != requestedRole ||
              !_selectableBackendRoles.contains(confirmedRole)) {
            await _authStorageService.clearActiveRole();
            if (confirmedRole.isNotEmpty) {
              await _authStorageService.storeRole(confirmedRole);
            }
            Get.snackbar(
              "Role Selection Failed",
              "The selected role could not be confirmed.",
              backgroundColor: Colors.red[600],
              colorText: Colors.white,
            );
            return;
          }

          _resetRoleNavigationState();
          await _authStorageService.storeAuthData(
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
            userId: data.user.id,
            role: confirmedRole,
          );
          await _authStorageService.storeActiveRole(confirmedRole);

          if (confirmedRole == 'instructor') {
            Get.offAll(() => const instructor_navigation.NavigationMenu());
          } else {
            Get.offAll(() => const BuyPlanScreen());
          }
        },
      );
    } catch (error) {
      Get.snackbar(
        "Role Selection Failed",
        "Unable to complete role selection. Please try again.",
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetRoleNavigationState() {
    if (Get.isRegistered<learner_navigation.NavigationController>()) {
      Get.delete<learner_navigation.NavigationController>(force: true);
    }
    if (Get.isRegistered<instructor_navigation.NavigationController>()) {
      Get.delete<instructor_navigation.NavigationController>(force: true);
    }
    if (Get.isRegistered<subscriber_navigation.NavbarController>()) {
      Get.delete<subscriber_navigation.NavbarController>(force: true);
    }
    if (Get.isRegistered<InstructorHomeController>()) {
      Get.delete<InstructorHomeController>(force: true);
    }
  }
}
