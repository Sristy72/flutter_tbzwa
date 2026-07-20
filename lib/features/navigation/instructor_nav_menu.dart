import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/common/widgets/app_scaffold.dart';
import '../../core/constants/assest_const.dart';
import '../../core/utils/app_svg.dart';
import '../instructor/screens/instructor_dashboard_screen.dart';
import '../instructor/screens/instructor_groups_screen.dart';
import '../instructor/screens/instructor_messages_screen.dart';
import '../instructor/screens/instructor_profile_screen.dart';
import '../instructor/screens/instructor_rooms_screen.dart';


class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the initial index from arguments (defaults to 0 if not provided)
    final int initialIndex = Get.arguments ?? 0;
    final controller = Get.put(
      NavigationController(initialIndex: initialIndex),
    );

    return Scaffold(
  
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(top: BorderSide(color: Color(0xFFFFFFFF))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(controller.items.length, (index) {
              final item = controller.items[index];
              final isSelected = controller.selectedIndex.value == index;

              return GestureDetector(
                onTap: () => controller.changeIndex(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvg(
                        asset: item['icon'],
                        height: 24,
                        color: item['label'] == 'Kora AI'
                            ? null
                            : (isSelected
                                  ? Color(0xFF4F46E5)
                                  : Color(0xFF94A3B8)
                                    ), // dim inactive
                      ),
                      const SizedBox(height: 4),

                      Text(
                        item['label'],
                        style: TextStyle(
                          color: isSelected
                              ? Color(0xFF4F46E5)
                              : Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  NavigationController({int initialIndex = 0}) {
    selectedIndex.value = initialIndex;
  }

  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      // 1 is Schedule
      try {
        // if (Get.isRegistered<ScheduleController>()) {
        //   final scheduleController = Get.find<ScheduleController>();
        //   scheduleController.fetchAppointments(
        //     status: scheduleController.selectedFilter.value,
        //   );
        // }
      } catch (e) {
        // Handle potential errors
      }
    } else if (index == 2) {
      // 2 is Chat
      try {
        // if (Get.isRegistered<ChatController>()) {
        //   Get.find<ChatController>().fetchChats();
        // }
      } catch (e) {
        // Handle potential errors
      }
    } else if (index == 4) {
      // 4 is Kora AI
      try {
        // if (Get.isRegistered<ChatbotController>()) {
        //   Get.find<ChatbotController>().fetchChatbot();
        // }
      } catch (e) {
        // Handle potential errors
      }
    }
  }

  final List<Map<String, dynamic>> items = [
    {'icon': AssetsConstants.images.home, 'label': 'Home'},
    {'icon': AssetsConstants.images.group, 'label': 'Groups'},
    {'icon': AssetsConstants.images.chat, 'label': 'Messages'},
    {'icon': AssetsConstants.images.room, 'label': 'Rooms'},
    {'icon': AssetsConstants.images.profile, 'label': 'Profile'},
  ];

  final List<Widget> screens = [
    const InstructorDashboardScreen(),
    const InstructorGroupsScreen(),
    const InstructorMessagesScreen(),
    const InstructorRoomsScreen(),
    const InstructorProfileScreen(),
  ];
}
