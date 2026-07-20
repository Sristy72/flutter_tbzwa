import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/navbar_menu.dart' as subscriber_navigation;
import 'package:flutter_tbzwa/navigation_menu.dart' as learner_navigation;
import 'package:get/get.dart';

import '../../../core/api/socket_client.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../instructor/controllers/instructor_groups_controller.dart';
import '../../instructor/controllers/instructor_home_controller.dart';
import '../../instructor/controllers/instructor_messages_controller.dart';
import '../../instructor/controllers/instructor_profile_controller.dart';
import '../../instructor/controllers/instructor_rooms_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/controllers/community_messages_controller.dart';
import '../../navigation/instructor_nav_menu.dart' as instructor_navigation;
import '../../auth/model/request/login_request.dart';
import '../../auth/model/request/register_request.dart';
import '../../auth/model/request/otp_request.dart';
import '../../auth/model/request/reset_password_request.dart';
import '../../auth/repositories/auth_repository.dart';
import 'role_selection_controller.dart';
import '../screens/role_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/verify_code_screen.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final AuthStorageService _authStorageService = AuthStorageService();

  // Form Controllers (can be used if needed, or passed from screens)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();

  // Reset Password controllers
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPassFormKey = GlobalKey<FormState>();
  final resetPassFormKey = GlobalKey<FormState>();

  // Interactive States
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isAgreedToTerms = false.obs;

  // @override
  // void onClose() {
  //   // Controllers are managed by the AuthController lifecycle.
  //   // Manual disposal is removed to prevent "used after disposed" errors during fast navigation transitions.
  //   super.onClose();
  // }

  // Toggles
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();
  void toggleTermsAgreement() => isAgreedToTerms.toggle();

  // --- Registration ---
  Future<void> register() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (!isAgreedToTerms.value) {
      Get.snackbar(
        "Terms & Conditions",
        "You must agree to the Terms and Conditions to continue.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return;
    }

    setLoading(true);
    clearError();

    final request = RegisterRequest(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      referralCode: referralCodeController.text.isNotEmpty
          ? referralCodeController.text.trim()
          : null,
    );

    final result = await _authRepo.register(request);

    setLoading(false);

    result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      },
      (success) {
        Get.snackbar(
          "Success",
          success.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        // Navigate to OTP Verification Screen
        Get.to(() => VerifyCodeScreen(email: emailController.text.trim()));
      },
    );
  }

  // --- Login ---
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    final request = LoginRequest(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final result = await _authRepo.login(request);

    setLoading(false);

    result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Login Failed",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      },
      (success) async {
        final data = success.data;
        _resetRoleNavigationState();
        await _authStorageService.clearActiveRole();
        await _authStorageService.storeAuthData(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          userId: data.user.id,
          role: data.user.role,
        );

        Get.snackbar(
          "Success",
          "Welcome back, ${data.user.fullName}!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );

        Get.offAll(() => const RoleSelectionScreen());
      },
    );
  }

  // --- Forgot Password ---
  Future<void> forgotPassword() async {
    if (!forgotPassFormKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    final email = emailController.text.trim();
    final result = await _authRepo.forgotPassword(email);

    setLoading(false);

    result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      },
      (success) {
        Get.snackbar(
          "Success",
          success.message,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        Get.to(() => VerifyCodeScreen(email: email, isForForgotPassword: true));
      },
    );
  }

  // --- Verify OTP for Reset ---
  Future<String?> verifyResetOTP(String email) async {
    if (otpController.text.length < 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid 6-digit OTP",
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return null;
    }

    setLoading(true);
    clearError();

    final request = OTPRequest(email: email, otp: otpController.text.trim());

    final result = await _authRepo.verifyResetOTP(request);

    setLoading(false);

    return result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        return null;
      },
      (success) => success.data, // This is the resetToken
    );
  }

  // --- Verify OTP for SignUp ---
  Future<bool> verifySignUpOTP(String email) async {
    if (otpController.text.length < 6) {
      Get.snackbar(
        "Error",
        "Please enter a valid 6-digit OTP",
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
      return false;
    }

    setLoading(true);
    clearError();

    final request = OTPRequest(email: email, otp: otpController.text.trim());

    final result = await _authRepo.verifyEmail(request);

    setLoading(false);

    return result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        return false;
      },
      (success) async {
        final data = success.data;
        _resetRoleNavigationState();
        await _authStorageService.clearActiveRole();
        await _authStorageService.storeAuthData(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          userId: data.user.id,
          role: data.user.role,
        );

        Get.snackbar(
          "Success",
          success.message,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        return true;
      },
    );
  }

  // --- Resend OTP ---
  Future<void> resendOTP(String email) async {
    setLoading(true);
    clearError();

    final result = await _authRepo.resendOTP(email);

    setLoading(false);

    result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      },
      (success) {
        Get.snackbar(
          "Success",
          success.message,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
      },
    );
  }

  // --- Reset Password ---
  Future<bool> resetPassword(String resetToken) async {
    if (!resetPassFormKey.currentState!.validate()) return false;

    setLoading(true);
    clearError();

    final request = ResetPasswordRequest(
      resetToken: resetToken,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    final result = await _authRepo.resetPassword(request);

    setLoading(false);

    return result.fold(
      (fail) {
        setError(fail.message);
        Get.snackbar(
          "Error",
          fail.message,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
        return false;
      },
      (success) {
        Get.snackbar(
          "Success",
          success.message,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        return true;
      },
    );
  }

  // --- Token Management ---
  Future<bool> refreshToken() async {
    final token = await _authStorageService.getRefreshToken();
    if (token == null) return false;

    final result = await _authRepo.refreshToken(token);

    return result.fold((fail) => false, (success) async {
      await _authStorageService.storeAccessToken(accessToken: success.data);
      return true;
    });
  }

  // --- Logout ---
  Future<void> logout() async {
    SocketClient().disconnect();
    await _authRepo.logout(); // Best effort backend logout
    await _authStorageService.clearAuthData();
    _resetRoleNavigationState();
    Get.delete<AuthController>();
    Get.offAll(() => const LoginScreen());
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
    if (Get.isRegistered<InstructorGroupsController>()) {
      Get.delete<InstructorGroupsController>(force: true);
    }
    if (Get.isRegistered<InstructorMessagesController>()) {
      Get.delete<InstructorMessagesController>(force: true);
    }
    if (Get.isRegistered<CommunityController>()) {
      Get.delete<CommunityController>(force: true);
    }
    if (Get.isRegistered<CommunityMessagesController>()) {
      Get.delete<CommunityMessagesController>(force: true);
    }
    if (Get.isRegistered<InstructorRoomsController>()) {
      Get.delete<InstructorRoomsController>(force: true);
    }
    if (Get.isRegistered<InstructorProfileController>()) {
      Get.delete<InstructorProfileController>(force: true);
    }
    if (Get.isRegistered<RoleSelectionController>()) {
      Get.delete<RoleSelectionController>(force: true);
    }
  }
}
