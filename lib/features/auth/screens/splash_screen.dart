import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Splash.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Obx(() {
            final videoController = controller.videoController;

            if (controller.isVideoInitialized.value &&
                videoController != null) {
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoController.value.size.width,
                    height: videoController.value.size.height,
                    child: VideoPlayer(videoController),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
