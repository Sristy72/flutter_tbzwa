import 'dart:async';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/learner_api_service.dart';
import '../services/voice_recording_api_service.dart';

enum RecordingState { initial, recording, paused, finished }

enum AudioRecordingMode { voice, summary }

class AudioRecordingController extends GetxController {
  AudioRecordingController({this.mode = AudioRecordingMode.voice});

  final AudioRecordingMode mode;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final VoiceRecordingApiService _recordingApiService =
      VoiceRecordingApiService();
  final LearnerApiService _learnerApiService = LearnerApiService();

  var state = RecordingState.initial.obs;
  var duration = 0.obs;
  var clipName = "".obs;
  var amplitude = 0.0.obs;
  var amplitudeHistory = <double>[].obs;
  var isSaving = false.obs;
  var profileName = ''.obs;
  Timer? _timer;
  Timer? _ampTimer;
  String? _path;

  @override
  void onInit() {
    super.onInit();
    _loadProfileName();
  }

  Future<void> _loadProfileName() async {
    try {
      final profile = await _learnerApiService.getProfile();
      profileName.value = profile.fullName.trim();
    } catch (_) {
      profileName.value = '';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.onClose();
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: _path!);

        state.value = RecordingState.recording;
        _startTimer();
        _startAmplitudeTimer();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _audioRecorder.pause();
      state.value = RecordingState.paused;
      _timer?.cancel();
      _ampTimer?.cancel();
    } catch (e) {
      Get.snackbar('Error', 'Failed to pause recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _audioRecorder.resume();
      state.value = RecordingState.recording;
      _startTimer();
      _startAmplitudeTimer();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resume recording: $e');
    }
  }

  Future<void> stopRecording() async {
    if (state.value != RecordingState.recording &&
        state.value != RecordingState.paused) {
      return;
    }
    try {
      final path = await _audioRecorder.stop();
      _path = path;
      if (path != null) state.value = RecordingState.finished;
      _timer?.cancel();
      _ampTimer?.cancel();
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording: $e');
    }
  }

  void resetRecording() {
    final oldPath = _path;
    _audioRecorder.stop();
    if (oldPath != null) {
      File(oldPath).delete().catchError((_) => File(oldPath));
    }
    _path = null;
    state.value = RecordingState.initial;
    duration.value = 0;
    clipName.value = "";
    amplitudeHistory.clear();
    _timer?.cancel();
    _ampTimer?.cancel();
  }

  Future<bool> saveRecording() async {
    if (isSaving.value) return false;
    final path = _path;
    if (state.value != RecordingState.finished || path == null) {
      Get.snackbar('Error', 'Please finish the recording before saving.');
      return false;
    }

    final audioFile = File(path);
    if (!await audioFile.exists()) {
      Get.snackbar('Error', 'The recorded audio file could not be found.');
      return false;
    }

    isSaving.value = true;
    try {
      if (mode == AudioRecordingMode.summary) {
        await _recordingApiService.uploadSummaryRecording(
          audioFile: audioFile,
          duration: duration.value,
          recordedAt: DateTime.now(),
          label: clipName.value,
        );
      } else {
        await _recordingApiService.uploadVoiceRecording(
          audioFile: audioFile,
          duration: duration.value,
          recordedAt: DateTime.now(),
          label: clipName.value,
        );
      }
      return true;
    } catch (error) {
      Get.snackbar(
        'Unable to save clip',
        error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration.value++;
    });
  }

  void _startAmplitudeTimer() {
    _ampTimer?.cancel();
    _ampTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) async {
      if (state.value != RecordingState.recording) {
        timer.cancel();
        return;
      }
      final amp = await _audioRecorder.getAmplitude();
      amplitude.value = amp.current;

      // Normalize amplitude for visualization (usually -160 to 0)
      // Let's convert it to a positive value between 0 and 1
      double normalized = (amp.current + 160) / 160;
      if (normalized < 0) normalized = 0;

      amplitudeHistory.add(normalized);
      if (amplitudeHistory.length > 40) {
        amplitudeHistory.removeAt(0);
      }
    });
  }

  String formatDuration() {
    final minutes = duration.value ~/ 60;
    final seconds = duration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
