import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';

import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/button_widgets.dart';
import '../controller/auth_controller.dart';

// Raw SVG icons for Google and Apple social buttons to ensure clean vector scaling
const String googleSvg =
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path fill="#EA4335" d="M12 5.04c1.66 0 3.2.57 4.38 1.69l3.27-3.27C17.68 1.54 14.98 1 12 1 7.35 1 3.37 3.65 1.39 7.56l3.86 3C6.16 7.6 8.84 5.04 12 5.04z"/>
  <path fill="#4285F4" d="M23.49 12.27c0-.81-.07-1.59-.2-2.34H12v4.43h6.44c-.28 1.47-1.11 2.71-2.36 3.55l3.66 2.84c2.14-1.97 3.39-4.87 3.39-8.52z"/>
  <path fill="#FBBC05" d="M5.25 14.44A7.18 7.18 0 0 1 4.8 12c0-.85.15-1.68.45-2.44L1.39 6.56C.5 8.2 0 10.04 0 12c0 1.96.5 3.8 1.39 5.44l3.86-3z"/>
  <path fill="#34A853" d="M12 18.96c-3.16 0-5.84-2.56-6.75-5.52l-3.86 3C3.37 20.35 7.35 23 12 23c2.98 0 5.73-1.04 7.67-2.83l-3.66-2.84c-1.07.73-2.43 1.63-4.01 1.63z"/>
</svg>''';

const String appleSvg =
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.82M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.21.67-2.93 1.49-.62.69-1.16 1.84-1.01 2.96 1.12.09 2.27-.56 2.95-1.39z"/>
</svg>''';

/// A custom painter that draws a dashed rounded rectangle, giving the referral code box its premium look.
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ),
    );

    final Path dashedPath = Path();
    double distance = 0.0;
    for (PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Ultra premium soft background
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Top Brand Logo
                // const SizedBox(height: 10),
                Center(
                  child: AppLogo(
                    images: 'assets/images/mainLogo.png',
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 24),

                /// Title Headers
                const Text(
                  "Create Your Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(
                      0xFF5151EF,
                    ), // Dynamic Brand Primary Purple/Blue
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Start your journey with Talk /BZ/",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                /// Full Name Input Field
                _buildTextField(
                  label: "Full Name",
                  placeholder: "Your Name",
                  controller: controller.nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Email Input Field
                _buildTextField(
                  label: "Email Address",
                  placeholder: "Your Email",
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your email";
                    }
                    if (!GetUtils.isEmail(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                /// Password Input Field
                Obx(
                  () => _buildTextField(
                    label: "Password",
                    placeholder: "Enter your password",
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                /// Confirm Password Input Field
                Obx(
                  () => _buildTextField(
                    label: "Confirm Password",
                    placeholder: "Confirm your password",
                    controller: controller.confirmPasswordController,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your password";
                      }
                      if (value != controller.passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                /// Agreement Checkbox Row
                Row(
                  children: [
                    Obx(
                      () => SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: controller.isAgreedToTerms.value,
                          onChanged: (val) => controller.toggleTermsAgreement(),
                          activeColor: const Color(0xFF5151EF),
                          side: const BorderSide(
                            color: Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "I agree to the Terms & Conditions",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Referral Code Box (Dotted Container styling)
                Builder(builder: (context) {
                  // Note: Referred logic can be updated in AuthController if needed
                  const isVerified = false; 
                  final primaryColor = isVerified
                      ? const Color(0xFF0F9B8E)
                      : const Color(0xFF5151EF);
                  final dashColor = isVerified
                      ? const Color(0xFF0F9B8E)
                      : const Color(0xFFC7C5FF);
                  final bgColor = isVerified
                      ? const Color(0xFFE6F9F6)
                      : const Color(0xFFEEEDFF);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DashedRectPainter(
                                color: dashColor,
                                strokeWidth: 1.5,
                                gap: 5.0,
                                dashLength: 6.0,
                                borderRadius: 16.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Referral Code(Optional)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isVerified
                                        ? const Color(0xFF0F9B8E)
                                        : const Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: controller.referralCodeController,
                                  decoration: InputDecoration(
                                    hintText: "Enter your friend's user ID",
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isVerified
                                            ? const Color(0xFF0F9B8E)
                                            : const Color(0xFFE5E7EB),
                                        width: isVerified ? 1.5 : 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isVerified
                                            ? const Color(0xFF0F9B8E)
                                            : const Color(0xFFE5E7EB),
                                        width: isVerified ? 1.5 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Color(0xFF0F9B8E),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Referred",
                                        style: TextStyle(
                                          color: Color(0xFF0F9B8E),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// Reward Info Alert Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? const Color(0xFFE6F9F6)
                              : const Color(0xFFE2E0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isVerified
                              ? "Friend will receive a reward automatically when you subscribe to any paid program."
                              : "If a friend invited you, enter their User ID here. They will earn a reward when you subscribe to a program.",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isVerified
                                ? const Color(0xFF0F9B8E)
                                : const Color(0xFF4A499E),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),

                /// Main "Create Account" Action Button
                PrimaryButton(
                  text: 'Create Account',
                  onApiPressed: controller.register,
                ),
                const SizedBox(height: 20),

                /// Separator OR text line
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Social Buttons Container
                _buildSocialButton(
                  text: "Continue With Google",
                  svgString: googleSvg,
                  onPressed: () {
                    // Google Auth Action
                  },
                ),
                const SizedBox(height: 12),

                _buildSocialButton(
                  text: "Continue With Apple",
                  svgString: appleSvg,
                  onPressed: () {
                    // Apple Auth Action
                  },
                ),
                const SizedBox(height: 24),

                /// Navigation Link to Sign In Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Action to navigate back to login screen
                        Get.back();
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xFF5151EF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to build form inputs with labels, placeholders, and proper active/inactive visual states.
  Widget _buildTextField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151), // Dark gray premium label
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF5151EF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            suffixIcon: suffixIcon,
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        ),
      ],
    );
  }

  /// Helper to build Google/Apple login buttons with clean vector SVG leading icons
  Widget _buildSocialButton({
    required String text,
    required String svgString,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6), // Smooth light gray fill
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(svgString, width: 20, height: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF374151), // Premium label charcoal
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
