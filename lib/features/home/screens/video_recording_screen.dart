import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/video_recording_controller.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  final VideoRecordingController controller = Get.put(
    VideoRecordingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF26A69A)),
          );
        }

        if (controller.videoState.value == VideoState.review) {
          return _buildReviewScreen();
        }

        return _buildRecordingScreen();
      }),
    );
  }

  Widget _buildRecordingScreen() {
    final cameraController = controller.cameraController!;
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF26A69A), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              ),
            ),
          ),
        ),

        // REC Indicator
        Positioned(
          top: 48,
          left: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "REC",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Overlay Text
        const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "1. What is the correct score call after deuce?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
              ),
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Switch Camera
              _buildControlBtn(
                Icons.cached_rounded,
                onTap: () => controller.switchCamera(),
              ),

              // Record Button
              GestureDetector(
                onTap: () {
                  if (controller.videoState.value == VideoState.recording) {
                    controller.stopRecording();
                  } else {
                    controller.startRecording();
                  }
                },
                child: Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: controller.videoState.value == VideoState.recording
                          ? Colors.white
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: controller.videoState.value == VideoState.recording
                        ? const Icon(
                            Icons.stop_rounded,
                            color: Colors.red,
                            size: 40,
                          )
                        : null,
                  ),
                ),
              ),

              // Thumbnail/Profile
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage("https://i.pravatar.cc/150?u=kathy"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Close Button
        Positioned(
          top: 48,
          right: 40,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            "Review Video",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 40),

          // Video Preview Placeholder (Matches Figma Teal Box)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Post-actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showNameDialog(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBECEE).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                      () => Text(
                        controller.clipName.value.isEmpty
                            ? "Name or tag this clip"
                            : controller.clipName.value,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        "Re-record",
                        const Color(0xFFEBECEE),
                        const Color(0xFF374151),
                        onTap: () => controller.resetRecording(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => _buildActionBtn(
                          controller.isSaving.value ? "Saving..." : "Save Clip",
                          const Color(0xFF26A69A),
                          Colors.white,
                          onTap: controller.isSaving.value
                              ? null
                              : () async {
                                  if (await controller.saveRecording()) {
                                    _showSuccessDialog();
                                  }
                                },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => controller.resetRecording(),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildActionBtn(
    String label,
    Color bg,
    Color text, {
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFFF0FDFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Great job, Kathy!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You've completed today's video recording task.\nKeep up the consistency!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: controller.clipName.value,
    );
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: "Name your clip",
      titleStyle: const TextStyle(
        color: Color(0xFF374151),
        fontWeight: FontWeight.bold,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          style: const TextStyle(color: Color(0xFF374151)),
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter clip name",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF26A69A)),
            ),
          ),
        ),
      ),
      confirm: TextButton(
        onPressed: () {
          controller.clipName.value = nameController.text;
          Get.back();
        },
        child: const Text(
          "Save",
          style: TextStyle(
            color: Color(0xFF26A69A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
