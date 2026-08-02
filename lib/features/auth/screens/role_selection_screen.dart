import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_logo.dart';
import '../../../core/common/widgets/app_scaffold.dart';
import '../controller/role_selection_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoleSelectionController());

    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Premium soft light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Matches exact visual screen in design (no top back)
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Top Brand Logo
              const SizedBox(height: 10),
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
                "Choose Your Role",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5151EF), // Dynamic Brand Primary Purple/Blue
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "How would you like to use Talk /BZ/?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),

              /// Prompt Label
              const Text(
                "Select an option to continue",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569), // Slate gray header
                ),
              ),
              const SizedBox(height: 12),

              /// Option: I am a learner
              Obx(() {
                final isSelected = controller.selectedRole.value == "learner";
                return _buildRoleCard(
                  text: "I am a learner",
                  isSelected: isSelected,
                  onTap: () => controller.selectRole("learner"),
                );
              }),
              const SizedBox(height: 16),

              /// Option: I am an instructor
              Obx(() {
                final isSelected =
                    controller.selectedRole.value == "instructor";
                return _buildRoleCard(
                  text: "I am an instructor",
                  isSelected: isSelected,
                  onTap: () => controller.selectRole("instructor"),
                );
              }),
              const SizedBox(height: 36),

              /// Continue Action Button
              SizedBox(
                height: 52,
                child: Obx(() {
                  final isSubmitting = controller.isSubmitting.value;
                  return ElevatedButton(
                    onPressed: isSubmitting ? null : controller.proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5151EF),
                      disabledBackgroundColor: const Color(0xFF5151EF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build interactive, state-driven role selection cards
  Widget _buildRoleCard({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEEDFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5151EF)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5151EF).withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF1E1B4B)
                : const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
