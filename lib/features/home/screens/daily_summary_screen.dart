import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/audio_recording_controller.dart';
import '../models/learner_api_models.dart';
import '../models/voice_recording_model.dart';
import '../services/learner_api_service.dart';
import '../services/voice_recording_api_service.dart';
import 'audio_recording_screen.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  final LearnerApiService _learnerApiService = LearnerApiService();
  final VoiceRecordingApiService _recordingApiService =
      VoiceRecordingApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedTab = 0; // 0 for Today's Task, 1 for History
  TodaySummaryTask? _summaryTask;
  List<SummaryHistoryEntry> _summaryHistory = const [];
  MissionProgress? _missionProgress;
  int _summaryRecordingsCount = 0;
  String? _playingRecordingId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingRecordingId = null);
    });
    _loadSummaryProgress();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSummaryProgress() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _learnerApiService.getTodaySummaryTask(),
        _learnerApiService.getDailyMissions(),
        _recordingApiService.getSummaryRecordingsForDate(DateTime.now()),
        _learnerApiService.getSummaryHistory(),
      ]);
      if (!mounted) return;
      final todaySummary = results[0] as TodaySummaryTask;
      final missions = results[1] as DailyMissionSummary;
      final recordings = results[2] as List;
      setState(() {
        _summaryTask = todaySummary;
        _missionProgress =
            missions.missions['summary'] ?? todaySummary.progress;
        _summaryRecordingsCount = recordings.length;
        _summaryHistory = results[3] as List<SummaryHistoryEntry>;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _completed {
    final apiCompleted = _missionProgress?.completed ?? 0;
    return apiCompleted > _summaryRecordingsCount
        ? apiCompleted
        : _summaryRecordingsCount;
  }

  int get _target => _missionProgress?.target ?? 2;

  String get _courseLabel => _summaryTask?.courseLabel.trim().isNotEmpty == true
      ? _summaryTask!.courseLabel
      : 'Summary';

  String get _timeLabel {
    final date = _summaryTask?.scheduledAt;
    if (date == null) return 'Today';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $suffix';
  }

  String get _instructorLabel =>
      _summaryTask?.instructorName.trim().isNotEmpty == true
      ? _summaryTask!.instructorName
      : 'Instructor';

  String get _summaryTitle => _summaryTask?.title.trim().isNotEmpty == true
      ? _summaryTask!.title
      : 'This is the summary of the last lesson';

  String get _lessonTitle => _summaryTask?.lessonTitle.trim().isNotEmpty == true
      ? _summaryTask!.lessonTitle
      : 'Daily Summary';

  String get _summaryText => _summaryTask?.summaryText.trim().isNotEmpty == true
      ? _summaryTask!.summaryText
      : 'No summary task is available yet.';

  Future<void> _openSummaryRecorder() async {
    if (_completed >= 3) {
      Get.snackbar(
        "Daily Summary",
        "You've reached today's 3 summary recordings limit.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await Get.to(
      () => const AudioRecordingScreen(mode: AudioRecordingMode.summary),
    );
    await _loadSummaryProgress();
  }

  Future<void> _playRecording(VoiceRecordingModel recording) async {
    if (recording.audioUrl.isEmpty) return;
    try {
      if (_playingRecordingId == recording.id) {
        await _audioPlayer.pause();
        if (mounted) setState(() => _playingRecordingId = null);
        return;
      }
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(recording.audioUrl));
      if (mounted) setState(() => _playingRecordingId = recording.id);
    } catch (_) {
      if (mounted) setState(() => _playingRecordingId = null);
      Get.snackbar('Unable to play audio', 'Please try again.');
    }
  }

  Future<void> _deleteRecording(VoiceRecordingModel recording) async {
    try {
      if (_playingRecordingId == recording.id) {
        await _audioPlayer.stop();
        if (mounted) setState(() => _playingRecordingId = null);
      }
      await _recordingApiService.deleteRecording(recording.id);
      await _loadSummaryProgress();
      Get.snackbar(
        'Recording deleted',
        'Your summary recording was removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Unable to delete recording',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF374151),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Daily Summary Task",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Tab Switcher
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBECEE).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTab(0, "Today's Task")),
                Expanded(child: _buildTab(1, "History")),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _selectedTab == 0 ? _buildTodayTask() : _buildHistory(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF26A69A)
                : const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF26A69A), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _courseLabel,
                      style: const TextStyle(
                        color: Color(0xFF26A69A),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _timeLabel,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Instructor: $_instructorLabel",
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Text(
          _summaryTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        // Summary Detail Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _lessonTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _summaryText,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF475569).withValues(alpha: 0.9),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Progress to Mastery",
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$_completed/$_target",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _target == 0
                      ? 0
                      : (_completed / _target).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE0F2F1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF26A69A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Record your summary $_target times to complete today's task",
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Bottom Actions
        ElevatedButton(
          onPressed: _isLoading ? null : _openSummaryRecorder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            "Start Recording $_completed/$_target",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "Read The Summary Out Loud",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildHistory() {
    final recordings = _summaryHistory
        .expand(
          (entry) => entry.recordings.map((recording) {
            final label = recording.label.trim().isEmpty
                ? 'Summary Recording'
                : recording.label.trim();
            return _SummaryHistoryRecording(
              recording: recording,
              title: entry.title,
              subtitle: '$label\n${recording.durationLabel}',
            );
          }),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Recordings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 20),
        if (recordings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No recordings yet.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
          )
        else
          ...recordings.map(
            (item) =>
                _buildHistoryItem(item.title, item.subtitle, item.recording),
          ),
      ],
    );
  }

  Widget _buildHistoryItem(
    String title,
    String subtitle,
    VoiceRecordingModel recording,
  ) {
    final isPlaying = _playingRecordingId == recording.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _playRecording(recording),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF26A69A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
            color: Colors.white,
            elevation: 4,
            onSelected: (value) {
              if (value == 'delete') _deleteRecording(recording);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryHistoryRecording {
  final VoiceRecordingModel recording;
  final String title;
  final String subtitle;

  const _SummaryHistoryRecording({
    required this.recording,
    required this.title,
    required this.subtitle,
  });
}
