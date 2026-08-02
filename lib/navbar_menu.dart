import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/features/community/screens/community_screen.dart';
import 'package:flutter_tbzwa/features/learn/screens/learn_screen.dart';
import 'package:flutter_tbzwa/features/profile/screens/profile_screen.dart';
import 'package:flutter_tbzwa/features/subcribers_flow/subscriber_community_screen.dart';
import 'package:flutter_tbzwa/features/subcribers_flow/subscriber_menu_drawer.dart';
import 'package:flutter_tbzwa/features/subcribers_flow/subscriber_profile_screen.dart';
import 'package:flutter_tbzwa/features/subcribers_flow/subscriber_voice_room_screen.dart';
import 'package:flutter_tbzwa/features/voice_room/screens/voice_room_screen.dart';
import 'package:get/get.dart';

import 'core/constants/assest_const.dart';
import 'core/utils/app_svg.dart';
import 'features/home/screens/home_screen.dart';
import 'features/subcribers_flow/subcriber_home.dart';
import 'features/subcribers_flow/subcriber_learn_screen.dart';

class NavbarMenu extends StatelessWidget {
  const NavbarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavbarController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 25),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(width: 2, color: Color(0xFFEAEDF1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(controller.items.length, (index) {
                final item = controller.items[index];
                final isSelected = controller.selectedIndex.value == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedIndex.value = index,
                    child: Container(
                      // duration: const Duration(milliseconds: 300),
                      // curve: Curves.easeInOut,
                      //margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: isSelected
                          ? const EdgeInsets.symmetric(vertical: 8)
                          : const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5456E7)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppSvg(
                            asset: item['icon'],
                            height: 20,
                            width: 20,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF90A4AE),
                              fontWeight: isSelected ? FontWeight.bold : null,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavbarController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<Map<String, dynamic>> items = [
    {'icon': NabIcon.home, 'label': 'Home'},
    {'icon': NabIcon.learn, 'label': 'Learn'},
    {'icon': NabIcon.community, 'label': 'Community'},
    {'icon': NabIcon.voiceRoom, 'label': 'Voice Room'},
    {'icon': NabIcon.profile, 'label': 'Profile'},
  ];

  final List<Widget> screens = [
    const SubscriberHome(),
    SubcriberLearnScreen(),
    SubscriberCommunityScreen(),
    SubscriberVoiceRoomScreen(),
    SubscriberProfileScreen(),
  ];
}
