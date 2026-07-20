import 'dart:convert';

import 'package:flutx_core/core/debug_print.dart';
import 'package:flutter_tbzwa/features/auth/screens/login_screen.dart';
import 'package:flutter_tbzwa/features/auth/screens/role_selection_screen.dart';
import 'package:flutter_tbzwa/navbar_menu.dart' as subscriber_navigation;
import 'package:flutter_tbzwa/navigation_menu.dart' as learner_navigation;
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/secure_store_services.dart';
import '../../instructor/controllers/instructor_home_controller.dart';
import '../../navigation/instructor_nav_menu.dart' as instructor_navigation;
import '../../onboarding/screens/onboarding_screen.dart';
import '../screens/role_selection_screen.dart';

class SplashController extends GetxController {
  final AuthStorageService _authStorageService = AuthStorageService();

  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool showSecondSplash = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startSplashFlow();
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }

  Future<void> _startSplashFlow() async {
    DPrint.log("SplashController: Starting splash flow...");

    const videoPath = 'assets/images/splash_video.mp4';
    DPrint.log("SplashController: Initializing video: $videoPath");

    // Initialize video controller
    videoController = VideoPlayerController.asset(videoPath);

    try {
      await videoController!.initialize();
      DPrint.log("SplashController: Video initialized successfully.");

      isVideoInitialized.value = true;

      await videoController!.play();
      DPrint.log("SplashController: Video playing...");

      // Wait for video to complete (with a fallback if duration is zero)
      final duration = videoController!.value.duration;
      if (duration.inMilliseconds > 0) {
        DPrint.log("SplashController: Waiting for video duration: $duration");
        await Future.delayed(duration);
      } else {
        DPrint.log(
          "SplashController: Video duration is zero, waiting for 5 seconds fallback.",
        );
        await Future.delayed(const Duration(seconds: 0));
      }
    } catch (e) {
      DPrint.error("SplashController: Error initializing video: $e");
      // If video fails, maybe show something else or just proceed
      await Future.delayed(const Duration(seconds: 3));
    }

    DPrint.log("SplashController: Navigating to next screen...");
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final secureStore = SecureStoreServices();
    final savedEmail = await secureStore.retrieveData("email");
    final savedPassword = await secureStore.retrieveData("password");

    final hasStoredSessionToken = await _authStorageService
        .hasStoredSessionToken();

    if (hasStoredSessionToken) {
      final role = await _resolveStartupRole();
      if (role != null) {
        _openDashboardForRole(role);
        return;
      }

      final accessToken = await _authStorageService.getAccessToken();
      if (accessToken?.isNotEmpty == true) {
        DPrint.warn(
          "SplashController: Session exists but role is unresolved. Opening role selection.",
        );
        _resetRoleNavigationState();
        Get.offAll(() => const RoleSelectionScreen());
        return;
      }
    }

    final isAuth = await _authStorageService.isAuthenticated();

    if (isAuth) {
      DPrint.warn(
        "SplashController: Legacy auth data found without resolved role. Opening role selection.",
      );
      _resetRoleNavigationState();
      Get.offAll(() => const RoleSelectionScreen());
    } else if (savedEmail != null && savedPassword != null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.off(() => const OnboardingScreen());
    }
  }

  Future<String?> _resolveStartupRole() async {
    final storedRole = _supportedRole(await _authStorageService.getRole());
    final activeRole = _supportedRole(
      await _authStorageService.getActiveRole(),
    );

    DPrint.log(
      "SplashController: startup roles -> stored=$storedRole active=$activeRole",
    );

    final restored = await ApiClient().restoreSession();
    DPrint.log("SplashController: restoreSession=$restored");

    final profileRole = restored ? await _fetchProfileRole() : null;
    if (profileRole != null) {
      await _authStorageService.storeRole(profileRole);
    }

    final tokenRole = await _roleFromAccessToken();
    if (tokenRole != null) {
      await _authStorageService.storeRole(tokenRole);
    }

    final hasValidSession = profileRole != null || tokenRole != null;
    if (!hasValidSession) {
      DPrint.warn("SplashController: No valid restored session or token role.");
      return null;
    }

    final accountRole = profileRole ?? tokenRole ?? storedRole;
    final finalRole = await _chooseStartupRole(
      activeRole: activeRole,
      accountRole: accountRole,
    );

    DPrint.log(
      "SplashController: resolved roles -> profile=$profileRole token=$tokenRole account=$accountRole final=$finalRole",
    );

    return finalRole;
  }

  Future<String?> _chooseStartupRole({
    required String? activeRole,
    required String? accountRole,
  }) async {
    if (accountRole == null) return null;
    if (activeRole == null) return accountRole;

    if (activeRole == 'subscriber') {
      if (accountRole == 'learner') return activeRole;

      DPrint.warn(
        "SplashController: stale subscriber active role for account=$accountRole. Clearing active role.",
      );
      await _authStorageService.clearActiveRole();
      return accountRole;
    }

    if (activeRole != accountRole) {
      DPrint.warn(
        "SplashController: stale active role active=$activeRole account=$accountRole. Clearing active role.",
      );
      await _authStorageService.clearActiveRole();
      return accountRole;
    }

    return activeRole;
  }

  Future<String?> _fetchProfileRole() async {
    final result = await ApiClient().get<Map<String, dynamic>>(
      endpoint: ApiConstants.user.profile,
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) return json;
        if (json is Map) return Map<String, dynamic>.from(json);
        return <String, dynamic>{};
      },
    );

    final profileData = result.fold<Map<String, dynamic>?>(
      (_) => null,
      (success) => success.data,
    );
    final user = profileData?['user'];
    if (user is! Map) return null;

    final userId = (user['id'] ?? user['_id'])?.toString();
    if (userId != null && userId.isNotEmpty) {
      await _authStorageService.storeUserId(userId);
    }

    return _supportedRole(user['role']);
  }

  Future<String?> _roleFromAccessToken() async {
    final accessToken = await _authStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final expiresAt = decoded['exp'];
      if (expiresAt is num) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (expiresAt <= now) {
          DPrint.warn("SplashController: access token role is expired.");
          return null;
        }
      }

      return _supportedRole(decoded['role']);
    } catch (error) {
      DPrint.error("SplashController: Failed to read token role: $error");
      return null;
    }
  }

  String? _supportedRole(dynamic value) {
    final role = value?.toString().trim().toLowerCase();
    if (role == 'instructor' || role == 'learner' || role == 'subscriber') {
      return role;
    }
    return null;
  }

  void _openDashboardForRole(String? role) {
    _resetRoleNavigationState();
    if (role == 'instructor') {
      DPrint.log("SplashController: route=instructor_navigation");
      Get.offAll(() => const instructor_navigation.NavigationMenu());
    } else if (role == 'subscriber') {
      DPrint.log("SplashController: route=subscriber_navigation");
      Get.offAll(() => const subscriber_navigation.NavbarMenu());
    } else if (role == 'learner') {
      DPrint.log("SplashController: route=learner_navigation");
      Get.offAll(() => const learner_navigation.NavigationMenu());
    } else {
      DPrint.warn("SplashController: Unknown role. Opening role selection.");
      Get.offAll(() => const RoleSelectionScreen());
    }
  }

  void _resetRoleNavigationState() {
    if (Get.isRegistered<learner_navigation.NavigationController>()) {
      DPrint.log("SplashController: deleting learner NavigationController");
      Get.delete<learner_navigation.NavigationController>(force: true);
    }
    if (Get.isRegistered<instructor_navigation.NavigationController>()) {
      DPrint.log("SplashController: deleting instructor NavigationController");
      Get.delete<instructor_navigation.NavigationController>(force: true);
    }
    if (Get.isRegistered<subscriber_navigation.NavbarController>()) {
      DPrint.log("SplashController: deleting subscriber NavbarController");
      Get.delete<subscriber_navigation.NavbarController>(force: true);
    }
    if (Get.isRegistered<InstructorHomeController>()) {
      DPrint.log("SplashController: deleting InstructorHomeController");
      Get.delete<InstructorHomeController>(force: true);
    }
  }
}
