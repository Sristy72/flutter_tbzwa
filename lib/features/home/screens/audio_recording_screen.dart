import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_recording_controller.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key, this.mode = AudioRecordingMode.voice});

  final AudioRecordingMode mode;

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  late final AudioRecordingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      AudioRecordingController(mode: widget.mode),
      tag: widget.mode.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF374151)),
          onPressed: () {
            controller.stopRecording();
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        final state = controller.state.value;
        final isFinished = state == RecordingState.finished;

        return Column(
          children: [
            const SizedBox(height: 20),
            // Header Label
            Text(
              _getStateLabel(state),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 48),

            // Timer
            Text(
              controller.formatDuration(),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26A69A),
              ),
            ),

            // Subtext
            if (!isFinished)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state == RecordingState.recording
                      ? "TAP MIC TO PAUSE"
                      : "TAP MIC TO START",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),

            const Spacer(),

            // Waveform / Dashed Line
            SizedBox(
              height: 100,
              width: double.infinity,
              child: _buildVisualizer(state),
            ),

            const Spacer(),

            // Bottom Controls
            _buildBottomControls(state),

            const SizedBox(height: 48),
          ],
        );
      }),
    );
  }

  String _getStateLabel(RecordingState state) {
    switch (state) {
      case RecordingState.initial:
        return "Record a Audio";
      case RecordingState.recording:
        return "Recording";
      case RecordingState.paused:
        return "Paused";
      case RecordingState.finished:
        return "Finish";
    }
  }

  Widget _buildVisualizer(RecordingState state) {
    if (state == RecordingState.paused) {
      return const DashedLineWidget();
    } else if (state == RecordingState.finished) {
      return StaticWaveformWidget(amplitudes: controller.amplitudeHistory);
    } else {
      return WaveformWidget(amplitudes: controller.amplitudeHistory);
    }
  }

  Widget _buildBottomControls(RecordingState state) {
    if (state == RecordingState.finished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Name field
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
                  child: _buildActionBtn(
                    "Save Clip",
                    const Color(0xFF26A69A),
                    Colors.white,
                    onTap: () async {
                      if (await controller.saveRecording()) {
                        _showSuccessDialog();
                      }
                    },
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel Button
        _buildCircularBtn(
          icon: Icons.close,
          color: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF94A3B8),
          onTap: () {
            controller.resetRecording();
            Get.back();
          },
        ),
        const SizedBox(width: 24),

        // Record/Pause Toggle
        GestureDetector(
          onTap: () {
            if (state == RecordingState.recording) {
              controller.pauseRecording();
            } else if (state == RecordingState.paused) {
              controller.resumeRecording();
            } else {
              controller.startRecording();
            }
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state == RecordingState.recording
                  ? Icons.pause_rounded
                  : Icons.mic_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Finish/Stop Button
        _buildCircularBtn(
          icon: Icons.stop_rounded,
          color: const Color(0xFFFA6E67),
          iconColor: Colors.white,
          size: 60,
          onTap: () => controller.stopRecording(),
        ),
      ],
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
              Obx(
                () => Text(
                  controller.profileName.value.isEmpty
                      ? "Great job!"
                      : "Great job, ${controller.profileName.value}!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You've completed today's voice recording task.\nKeep up the consistency!",
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
                  Get.back(); // Close dialog
                  Get.back(result: true); // Return and refresh the daily list
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
          style: TextStyle(color: Color(0xFF374151)),
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

  Widget _buildCircularBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }

  Widget _buildActionBtn(
    String label,
    Color bg,
    Color text, {
    required VoidCallback onTap,
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
}

class WaveformWidget extends StatelessWidget {
  final List<double> amplitudes;
  const WaveformWidget({super.key, required this.amplitudes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: WaveformPainter(amplitudes));
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  WaveformPainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26A69A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final middle = size.height / 2;
    const spacing = 8.0;
    final totalWidth = amplitudes.length * spacing;
    final startX = (size.width - totalWidth) / 2;

    for (var i = 0; i < amplitudes.length; i++) {
      final amp = amplitudes[i];
      final h = amp * 60 + 5; // Min height 5
      canvas.drawLine(
        Offset(startX + i * spacing, middle - h / 2),
        Offset(startX + i * spacing, middle + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DashedLineWidget extends StatelessWidget {
  const DashedLineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(double.infinity, 2),
        painter: DashedLinePainter(),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26A69A)
      ..strokeWidth = 2;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    double startX = 60;
    final endX = size.width - 60;

    while (startX < endX) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StaticWaveformWidget extends StatelessWidget {
  final List<double> amplitudes;
  const StaticWaveformWidget({super.key, required this.amplitudes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(amplitudes), // Same painter but no animation
    );
  }
}
