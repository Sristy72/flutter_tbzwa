import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bz_pad/screens/bz_pad_splash_screen.dart';
import 'daily_video_recording_screen.dart';
import 'daily_voice_recording_screen.dart';
import 'daily_vocabulary_screen.dart';
import 'daily_summary_screen.dart';
import 'daily_immersion_screen.dart';
import '../models/learner_api_models.dart';
import '../services/learner_api_service.dart';

class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen> {
  final LearnerApiService _learnerApiService = LearnerApiService();
  DailyMissionSummary? _missions;
  bool _isLoadingMissions = false;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    if (_isLoadingMissions) return;

    _isLoadingMissions = true;
    try {
      while (mounted) {
        try {
          final missions = await _learnerApiService.getDailyMissions();
          if (mounted) setState(() => _missions = missions);
          return;
        } catch (_) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } finally {
      _isLoadingMissions = false;
    }
  }

  MissionProgress? _mission(String key) => _missions?.missions[key];

  String _missionStatus(String key, int fallbackTarget) {
    final mission = _mission(key);
    final completed = mission?.completed ?? 0;
    final target = mission?.target ?? fallbackTarget;
    return '$completed/$target ${completed >= target ? 'complete' : 'in progress'}';
  }

  bool _missionDone(String key) {
    final mission = _mission(key);
    return mission != null && mission.completed >= mission.target;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF374151),
              size: 20,
            ),
            onPressed: () => Get.back(result: true),
          ),
          title: const Text(
            "Daily Missions",
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const DailyVoiceRecordingScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily Voice",
                      _missionStatus('voiceRecordings', 3),
                      "assets/images/voice.png",
                      statusColor: _missionDone('voiceRecordings')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('voiceRecordings'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const DailyVideoRecordingScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily Video",
                      _missionStatus('videoRecordings', 3),
                      'assets/images/video.png',
                      statusColor: _missionDone('videoRecordings')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('videoRecordings'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const DailyVocabularyScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily Vocabulary",
                      _missionStatus('vocabulary', 2),
                      'assets/images/vocabulary.png',
                      label: "Aa",
                      statusColor: _missionDone('vocabulary')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('vocabulary'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const DailySummaryScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily Summary",
                      _missionStatus('summary', 2),
                      'assets/images/summary.png',
                      statusColor: _missionDone('summary')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('summary'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const DailyImmersionScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily English Imrs.",
                      _missionStatus('immersion', 3),
                      "assets/images/eng_immerce.png",
                      statusColor: _missionDone('immersion')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('immersion'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Get.to(() => const BZPadSplashScreen());
                      await _loadMissions();
                    },
                    child: _buildMissionCard(
                      "Daily BZPad",
                      _missionStatus('bzpad', 1),
                      "assets/images/bzpad.png",
                      statusColor: _missionDone('bzpad')
                          ? Colors.green
                          : Colors.orange,
                      isDone: _missionDone('bzpad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWideMissionCard(
                "Switch Everything In English",
                _missionStatus('switchToEnglish', 1),
                Icons.star_outline_rounded,
                statusColor: _missionDone('switchToEnglish')
                    ? Colors.green
                    : const Color(0xFF26A69A),
                isDone: _missionDone('switchToEnglish'),
              ),
              const SizedBox(width: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCard(
    String title,
    String status,
    String image, {
    String? label,
    required Color statusColor,
    bool isDone = false,
    bool isReminder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEAEDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F7FA),
              shape: BoxShape.circle,
            ),
            child: label != null
                ? Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF26A69A),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : Image.asset(
                    image,
                    color: const Color(0xFF26A69A),
                    width: 24,
                    height: 24,
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isReminder
                    ? Icons.star
                    : (isDone
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined),
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideMissionCard(
    String title,
    String status,
    IconData icon, {
    required Color statusColor,
    bool isDone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F7FA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF26A69A), size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_outline_rounded : Icons.star,
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
