import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/navbar_menu.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import '../../../core/services/auth_storage_service.dart';
import '../controller/buy_plan_controller.dart';
import 'immersion_plans_screen.dart';

class BuyPlanScreen extends StatelessWidget {
  const BuyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BuyPlanController());

    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Buy Plan",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            /// Plan Option 1: Self Learning System
            ///
            // Obx(() {
            //   final isSelected = controller.selectedPlan.value == 1;
            //   return _buildPlanCard(
            //     number: 1,
            //     title: "Non Paid Learning System",
            //     subtitle: null,
            //     isSelected: isSelected,
            //     onTap: () {
            //       controller.selectPlan(1);
            //       Get.to(() =>  NavbarMenu());
            //     },
            //   );
            // }),
            //const SizedBox(height: 16),
            Obx(() {
              final isSelected = controller.selectedPlan.value == 2;
              return _buildPlanCard(
                number: 1,
                title: "Self Learning System",
                subtitle: null,
                isSelected: isSelected,
                onTap: () async {
                  controller.selectPlan(2);
                  await AuthStorageService().storeActiveRole('subscriber');
                  Get.to(() => NavbarMenu());
                },
              );
            }),
            const SizedBox(height: 16),

            /// Plan Option 2: Live Learning System
            Obx(() {
              final isSelected = controller.selectedPlan.value == 3;
              return _buildPlanCard(
                number: 2,
                title: "Live Learning System",
                subtitle: "(Immersion++ Plans)",
                isSelected: isSelected,
                onTap: () {
                  controller.selectPlan(3);
                  Get.to(() => const ImmersionPlansScreen());
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Builds a selectable plan card with a number badge on the left
  Widget _buildPlanCard({
    required int number,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFFFF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5151EF)
                : const Color(0xFF94A3B8).withOpacity(0.20),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            /// Number badge
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEEEEFD)
                    : const Color(0xFFEEEEFD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFEEEEFD)
                      : const Color(0xFFEEEEFD),
                  width: 1,
                ),
              ),
              child: Text(
                "$number",
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF000000)
                      : const Color(0xFF000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),

            /// Title and optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF374151)
                          : const Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    // Text(
                    //   subtitle,
                    //   style: TextStyle(
                    //     color: isSelected
                    //         ? const Color(0xFF374151)
                    //         : const Color(0xFF374151),
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
