import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../services/voice_recording_api_service.dart';

enum VideoState { initial, recording, review }

class VideoRecordingController extends GetxController {
  final VoiceRecordingApiService _recordingApiService =
      VoiceRecordingApiService();
  CameraController? cameraController;
  List<CameraDescription> cameras = const [];
  bool _isControllerClosed = false;

  var isInitialized = false.obs;
  var videoState = VideoState.initial.obs;
  var recordedVideoPath = "".obs;
  var clipName = "".obs;
  var duration = 0.obs;
  var isSaving = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  @override
  void onClose() {
    _isControllerClosed = true;
    _timer?.cancel();
    isInitialized.value = false;
    cameraController?.dispose();
    cameraController = null;
    super.onClose();
  }

  Future<void> _initializeCamera() async {
    CameraController? newController;
    try {
      cameras = await availableCameras();
      if (_isControllerClosed) return;
      if (cameras.isEmpty) {
        Get.snackbar("Error", "No camera is available on this device.");
        return;
      }

      newController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: true,
      );
      cameraController = newController;
      await newController.initialize();
      if (_isControllerClosed) {
        await newController.dispose();
        return;
      }
      isInitialized.value = true;
    } catch (e) {
      if (identical(cameraController, newController)) {
        cameraController = null;
      }
      await newController?.dispose();
      if (_isControllerClosed) return;
      Get.snackbar("Error", "Failed to initialize camera: $e");
    }
  }

  Future<void> switchCamera() async {
    final currentController = cameraController;
    if (!isInitialized.value || currentController == null) return;

    final targetDirection =
        currentController.description.lensDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    final matchingCameras = cameras.where(
      (description) => description.lensDirection == targetDirection,
    );
    if (matchingCameras.isEmpty) {
      Get.snackbar("Error", "No other camera is available on this device.");
      return;
    }

    isInitialized.value = false;
    CameraController? newController;
    try {
      await currentController.dispose();
      newController = CameraController(
        matchingCameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );
      cameraController = newController;
      await newController.initialize();
      if (_isControllerClosed) {
        await newController.dispose();
        return;
      }
      isInitialized.value = true;
    } catch (e) {
      if (identical(cameraController, newController)) {
        cameraController = null;
      }
      await newController?.dispose();
      if (_isControllerClosed) return;
      Get.snackbar("Error", "Failed to switch camera: $e");
    }
  }

  Future<void> startRecording() async {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isRecordingVideo) return;

    try {
      await controller.startVideoRecording();
      videoState.value = VideoState.recording;
      _startTimer();
    } catch (e) {
      Get.snackbar("Error", "Failed to start recording: $e");
    }
  }

  Future<void> stopRecording() async {
    final controller = cameraController;
    if (controller == null || !controller.value.isRecordingVideo) return;

    try {
      final XFile file = await controller.stopVideoRecording();
      recordedVideoPath.value = file.path;
      videoState.value = VideoState.review;
      _timer?.cancel();
    } catch (e) {
      Get.snackbar("Error", "Failed to stop recording: $e");
    }
  }

  void resetRecording() {
    final oldPath = recordedVideoPath.value;
    videoState.value = VideoState.initial;
    recordedVideoPath.value = "";
    clipName.value = "";
    duration.value = 0;
    _timer?.cancel();
    if (oldPath.isNotEmpty) {
      File(oldPath).delete().catchError((_) => File(oldPath));
    }
  }

  Future<bool> saveRecording() async {
    if (isSaving.value) return false;
    final path = recordedVideoPath.value;
    if (videoState.value != VideoState.review || path.isEmpty) {
      Get.snackbar("Error", "Please finish the recording before saving.");
      return false;
    }

    final videoFile = File(path);
    if (!await videoFile.exists()) {
      Get.snackbar("Error", "The recorded video file could not be found.");
      return false;
    }

    isSaving.value = true;
    try {
      await _recordingApiService.uploadVideoRecording(
        videoFile: videoFile,
        duration: duration.value,
        recordedAt: DateTime.now(),
        label: clipName.value,
      );
      return true;
    } catch (error) {
      Get.snackbar(
        "Unable to save clip",
        error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    duration.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration.value++;
    });
  }
}
