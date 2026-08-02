import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/common/widgets/button_widgets.dart';
import '../controller/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Ultra premium soft background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Clean login screen layout
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Form(
            key: controller.loginFormKey,
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
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(
                      0xFF5151EF,
                    ), // Dynamic Brand Primary Purple/Blue
                    //letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Sign in to continue your learning",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF000055),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 63),

                /// Email Input Field with exact French placeholder hint
                _buildTextField(
                  label: "Email Address",
                  placeholder: "Adresse e-mail",
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

                /// Password Input Field with exact French placeholder hint
                Obx(
                  () => _buildTextField(
                    label: "Password",
                    placeholder: "Mot de passe",
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
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),

                /// Forgot Password clickable action
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF5151EF),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                /// Main "Sign In" Action Button
                PrimaryButton(text: 'Sign In', onApiPressed: controller.login),
                const SizedBox(height: 24),

                /// Separator line with small "or" text
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xFFE5E7EB), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or",
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
                const SizedBox(height: 24),

                /// Social Buttons in small centered squares side-by-side
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialSquareButton(
                      svgString: googleSvg,
                      onPressed: () {
                        // Google Auth Action
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildSocialSquareButton(
                      svgString: appleSvg,
                      onPressed: () {
                        // Apple Auth Action
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                /// Navigation Link to Sign Up Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignUpScreen());
                      },
                      child: const Text(
                        "Sign Up",
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
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
            hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCECECE), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCECECE), width: 1),
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

  /// Helper to build Google/Apple login buttons as small square blocks
  Widget _buildSocialSquareButton({
    required String svgString,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 56,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6), // Smooth light gray fill
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Center(
          child: SvgPicture.string(svgString, width: 20, height: 20),
        ),
      ),
    );
  }
}
