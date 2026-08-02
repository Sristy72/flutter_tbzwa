import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'all_set_screen.dart';

class KeysToSuccessScreen extends StatelessWidget {
  const KeysToSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact list of keys matching the image descriptions
    final List<Map<String, dynamic>> keysData = [
      {
        "title": "Switch your world to English",
        "desc":
            "Change the language of all your devices (phone, computer, social media) to English.",
        "image": "assets/images/language.png",
        "fallbackIcon": Icons.translate_rounded,
      },
      {
        "title": "Use Our Interactive Notebook BZPad",
        "desc":
            "Use the BZPad to save your new vocabulary, phrases, and thoughts daily.",
        "image": "assets/images/notebook.png",
        "fallbackIcon": Icons.event_note_rounded,
      },
      {
        "title": "Daily English Immersion (5-10 min)",
        "desc":
            "Listen to or watch something you love in English every single day (Podcasts, YouTube, Netflix).",
        "image": "assets/images/volume.png",
        "fallbackIcon": Icons.volume_up_rounded,
      },
      {
        "title": "Record your Voice (3 min)",
        "desc":
            "Record 3 audio clips (45-60 sec each) to track your progress and gain confidence.",
        "image": "assets/images/record_voice.png",
        "fallbackIcon": Icons.radio_button_checked_rounded,
      },
      {
        "title": "Film your Progress (3 min)",
        "desc":
            "Record 3 short videos (45-60 sec each). Seeing yourself speak is the best way to improve!",
        "image": "assets/images/camera.png",
        "fallbackIcon": Icons.text_fields_rounded,
      },
      {
        "title": "The \"2-2-2\" Routine (8-9 min)",
        "desc":
            "Find 2 new words, write their meaning, and create 2 example sentences for each.",
        "image": "assets/images/video_camera.png",
        "fallbackIcon": Icons.text_fields_rounded,
      },
      {
        "title": "Summary Reading",
        "desc":
            "Write a short summary ( 5 - 7 min ) of what you learned today, then read it aloud twice.",
        "image": "assets/images/edit.png",
        "fallbackIcon": Icons.edit_rounded,
      },
    ];

    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Top Segmented Progress Indicators (Step 1 and 2 active)
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5151EF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5151EF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Screen Title
              const Text(
                "The 7 Keys to Success",
                style: TextStyle(
                  color: Color(0xFF191C1F),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  // letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 51),

              // Scrollable keys list
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  itemCount: keysData.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = keysData[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon card container
                        Container(
                          width: 48,
                          height: 48,
                          // decoration: BoxDecoration(
                          //   color: const Color(0xFF5151EF).withAlpha(217),
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            item["image"] as String,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                item["fallbackIcon"] as IconData,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"] as String,
                                style: const TextStyle(
                                  color: Color(0xFF191C1F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["desc"] as String,
                                style: const TextStyle(
                                  color: Color(0xFF191C1F),
                                  fontSize: 10,
                                  height: 1.3,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Action Ready to Start Button
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const AllSetScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5151EF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Ready to Start",
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
