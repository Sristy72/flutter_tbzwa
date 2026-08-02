import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/features/bz_wallet/screens/bz_wallet_splash_screen.dart';
import 'package:flutter_tbzwa/features/library/screens/library_splash_screen.dart';
import 'package:get/get.dart';
import '../../../navigation_menu.dart';
import '../../bz_pad/screens/bz_pad_splash_screen.dart';
import '../../daily_mission/screens/daily_mission_splash_screen.dart';
import 'audio_recording_screen.dart';
import 'daily_mission_screen.dart';
import 'daily_video_recording_screen.dart';
import '../models/learner_api_models.dart';
import '../services/learner_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LearnerApiService _api = LearnerApiService();
  LearnerProfile? _profile;
  DailyMissionSummary? _missions;
  bool _isLoadingHomeData = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData({bool retryUntilSuccess = false}) async {
    if (_isLoadingHomeData) return;

    _isLoadingHomeData = true;
    try {
      while (mounted) {
        try {
          final values = await Future.wait([
            _api.getProfile(),
            _api.getDailyMissions(),
          ]);
          if (!mounted) return;
          setState(() {
            _profile = values[0] as LearnerProfile;
            _missions = values[1] as DailyMissionSummary;
          });
          return;
        } catch (_) {
          if (!retryUntilSuccess) return;
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } finally {
      _isLoadingHomeData = false;
    }
  }

  String get _firstName {
    final name = _profile?.fullName.trim() ?? '';
    return name.isEmpty ? 'Learner' : name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGoalCard(),
              const SizedBox(height: 30),
              _buildSectionHeader(
                "Daily Missions",
                "not",
                onTap: () async {
                  final shouldRefresh = await Get.to(
                    () => const DailyMissionsScreen(),
                  );
                  if (shouldRefresh == true) {
                    await _loadHomeData(retryUntilSuccess: true);
                  }
                },
              ),
              _buildDailyMissions(),
              const SizedBox(height: 30),
              _buildSectionHeader(
                "Learning Programs",
                "not",
                onTap: () =>
                    Get.find<NavigationController>().selectedIndex.value = 1,
              ),
              _buildLearningPrograms(),
              const SizedBox(height: 30),
              _buildSectionHeader("Quick Access", 'quick'),
              _buildQuickAccess(),
              const SizedBox(height: 20), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: _profile?.profileImageUrl?.isNotEmpty == true
              ? NetworkImage(_profile!.profileImageUrl!)
              : const AssetImage('assets/images/default_user_avatar.png')
                    as ImageProvider,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rise and shine!",
              style: TextStyle(color: Color(0xFF374151), fontSize: 14),
            ),
            Text(
              _profile?.fullName.isNotEmpty == true
                  ? _profile!.fullName
                  : "Kathy Onana",
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF263238),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    final progress = (_missions?.overallProgress ?? 0).clamp(0, 100);
    final remaining =
        ((_missions?.totalCount ?? 0) - (_missions?.completedCount ?? 0)).clamp(
          0,
          100,
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF22A892),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Goal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$progress%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Keep up the streak, $_firstName!",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                "Completed",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFF146456),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Color(0xFF374151)),
                    SizedBox(width: 4),
                    Text(
                      "On Track",
                      style: TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$remaining tasks remaining",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (text != 'quick')
            GestureDetector(
              onTap: onTap,
              child: Text(
                'View all',
                style: TextStyle(
                  color: Colors.blueGrey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyMissions() {
    final audio = _missions?.missions['voiceRecordings'];
    final video = _missions?.missions['videoRecordings'];
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => AudioRecordingScreen()),
            child: _buildMissionCard(
              "Daily Audio",
              "${audio?.completed ?? 0}/${audio?.target ?? 3} ${audio != null && audio.completed >= audio.target ? 'complete' : 'in progress'}",
              'assets/images/voice.png',
              const Color(0xFFE0F2F1),
              const Color(0xFF26A69A),
              isDone: audio != null && audio.completed >= audio.target,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const DailyVideoRecordingScreen()),
            child: _buildMissionCard(
              "Daily Video",
              "${video?.completed ?? 0}/${video?.target ?? 3} ${video != null && video.completed >= video.target ? 'complete' : 'in progress'}",
              "assets/images/video.png",
              const Color(0xFFE1F5FE),
              const Color(0xFF03A9F4),
              isDone: video != null && video.completed >= video.target,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(
    String title,
    String status,
    String image,
    Color bg,
    Color iconColor, {
    bool isDone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
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
            decoration: BoxDecoration(
              color: Color(0xFFEAFDFA),
              shape: BoxShape.circle,
            ),
            child: Image.asset(image, width: 24, height: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isDone
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                size: 14,
                color: isDone ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPrograms() {
    return Column(
      children: [
        _buildProgramCard(
          "START ZONE",
          "Beginner",
          'assets/images/book-closed (1).png',
          const Color(0xFF0186B3),
          const Color(0xFF00AEE9),
        ),
        const SizedBox(height: 16),
        _buildProgramCard(
          "START ZONE+",
          "Advanced Beginner",
          "assets/images/book-closed.png",
          const Color(0xFFFF5C20),
          const Color(0xFFFD936C),
        ),
      ],
    );
  }

  Widget _buildProgramCard(
    String title,
    String subtitle,
    String image,
    Color color1,
    color2,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(image, color: color1, width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickAccessItem(
            "BZPad",
            const Color(0xFF5C6BC0),
            "assets/images/bz_pad.png",
            () => Get.to(() => BZPadSplashScreen()),
          ),
          _buildQuickAccessItem(
            "BZ-WALLET",
            const Color(0xFFFDD835),
            "assets/images/bzwallet.png",
            () => Get.to(() => BZWalletSplashScreen()),
          ),
          _buildQuickAccessItem(
            "BZ-Library",
            const Color(0xFF42A5F5),
            "assets/images/library.png",
            () => Get.to(() => LibrarySplashScreen()),
          ),
          _buildQuickAccessItem(
            "BZ-Daily Missions",
            const Color(0xFF66BB6A),
            "assets/images/daily_mission.png",
            () => Get.to(() => DailyMissionSplashScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(
    String label,
    Color color,
    String image,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(image, width: 32, height: 24),
            ),
            const SizedBox(height: 8),
            // Text(
            //   label,
            //   style: const TextStyle(
            //     color: Color(0xFF455A64),
            //     fontSize: 12,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
