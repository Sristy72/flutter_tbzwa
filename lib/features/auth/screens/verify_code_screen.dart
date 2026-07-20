import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/button_widgets.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String email;
  final bool isForForgotPassword;
  const VerifyCodeScreen({
    super.key,
    required this.email,
    this.isForForgotPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    // Using a simple state for OTP input demonstration
    // In production, use PinCodeTextField or similar
    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF111827),
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: AppLogo(
                images: 'assets/images/mainLogo.png',
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Verify OTP",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We've sent a 6-digit verification code to\n$email",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            /// OTP Input Field
            TextFormField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
                color: Color(0xFF111827),
              ),
              decoration: InputDecoration(
                hintText: "000000",
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF).withOpacity(0.5),
                  letterSpacing: 12,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF5151EF),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    if (isForForgotPassword) {
                      controller.forgotPassword();
                    } else {
                      controller.resendOTP(email);
                    }
                  },
                  child: const Text(
                    "Resend",
                    style: TextStyle(
                      color: Color(0xFF5151EF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            /// Main Action Button
            PrimaryButton(
              text: 'Verify Code',
              onApiPressed: () async {
                if (isForForgotPassword) {
                  final token = await controller.verifyResetOTP(email);
                  if (token != null) {
                    Get.to(() => ResetPasswordScreen(resetToken: token));
                  }
                } else {
                  final success = await controller.verifySignUpOTP(email);
                  if (success) {
                    // Manually cleanup before clearing stack to avoid race conditions with disposal
                    Get.delete<AuthController>();
                    Get.offAll(() => const LoginScreen());
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
