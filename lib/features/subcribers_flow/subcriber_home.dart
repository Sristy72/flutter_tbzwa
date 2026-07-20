import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'subscriber_choose_program_screen.dart';
import '../bz_pad/screens/bz_pad_splash_screen.dart';
import '../bz_wallet/screens/bz_wallet_splash_screen.dart';
import '../bz_wallet/screens/top_up_screen.dart';
import '../library/screens/library_splash_screen.dart';
import '../daily_mission/screens/daily_mission_splash_screen.dart';
import 'subscriber_menu_drawer.dart';
import '../home/models/learner_api_models.dart';
import '../home/screens/daily_mission_screen.dart';
import '../home/screens/daily_summary_screen.dart';
import '../home/screens/daily_video_recording_screen.dart';
import '../home/screens/daily_voice_recording_screen.dart';
import '../home/screens/daily_vocabulary_screen.dart';
import '../home/services/learner_api_service.dart';

class SubscriberHome extends StatefulWidget {
  const SubscriberHome({super.key});

  @override
  State<SubscriberHome> createState() => _SubscriberHomeState();
}

class _SubscriberHomeState extends State<SubscriberHome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final LearnerApiService _learnerApiService = LearnerApiService();
  LearnerProfile? _profile;
  DailyMissionSummary? _missions;
  LearnerLiveClasses? _liveClasses;
  bool _isLoadingHome = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoadingHome = true);
    try {
      final results = await Future.wait<dynamic>([
        _learnerApiService.getProfile(),
        _learnerApiService.getDailyMissions(),
        _learnerApiService.getLiveClasses(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as LearnerProfile;
        _missions = results[1] as DailyMissionSummary;
        _liveClasses = results[2] as LearnerLiveClasses;
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoadingHome = false);
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

  String get _learnerName {
    final name = _profile?.fullName.trim();
    return name == null || name.isEmpty ? 'Learner' : name;
  }

  String get _learnerId {
    final userId = _profile?.userId.trim();
    return userId == null || userId.isEmpty ? 'BZ - 284910' : userId;
  }

  String get _planLabel {
    final plan = _profile?.plan ?? 'pro';
    if (plan == 'none') return 'PRO';
    return plan.replaceAll('_', ' ').toUpperCase();
  }

  String get _balanceLabel =>
      '\$${(_profile?.walletBalance ?? 0).toStringAsFixed(2)}';

  int get _goalProgress => _missions?.overallProgress ?? 0;

  int get _remainingTasks {
    final missions = _missions;
    if (missions == null) return 0;
    return missions.totalCount - missions.completedCount;
  }

  LiveClassInfo? get _nextLiveClass {
    final today = _liveClasses?.today ?? const <LiveClassInfo>[];
    if (today.isNotEmpty) return today.first;
    final upcoming = _liveClasses?.upcoming ?? const <LiveClassInfo>[];
    return upcoming.isEmpty ? null : upcoming.first;
  }

  String _formatClassTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  Future<void> _openMission(Widget screen) async {
    await Get.to(() => screen);
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: Stack(
        children: [
          // ─── Main Content (Blurred) ──────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildBlurredSection(_buildTodayGoalCard()),

                      const SizedBox(height: 30),
                      _buildSectionHeader(
                        "Daily Missions",
                        'yes',
                        onSeeAll: () async {
                          await Get.to(() => const DailyMissionsScreen());
                          await _loadHomeData();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDailyMissionsGrid(),
                      const SizedBox(height: 30),
                      const Text(
                        "Next Live Class",
                        style: TextStyle(
                          color: Color(0xFF263238),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBlurredSection(_buildNextLiveClassCard()),

                      const SizedBox(height: 30),
                      _buildSectionHeader(
                        "Quick Access",
                        'no',
                        onSeeAll: () {},
                      ),
                      const SizedBox(height: 16),
                      _buildQuickAccessList(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Unblurred Header ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  //   child: const Icon(Icons.menu, color: Colors.white, size: 28),
                  // ),
                  //const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bonjour,",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        _learnerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _planLabel,
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black,
                    ),
                  ),
                  //const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5151EF),
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(30),
        //   bottomRight: Radius.circular(30),
        // ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        children: [
          const SizedBox(height: 40), // Space for the fixed header
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF6666EE),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Color(0xFF8585F1)),
                ),
                child: GestureDetector(
                  onTap: () => Get.to(() => const TopUpScreen()),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: Color(0xFFFFFFFF),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TalkCoin Balance",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            _balanceLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F5CD1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ).copyWith(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    child: const Text(
                      "Give interview",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Text(
                      "ID : $_learnerId",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoalCard() {
    return Container(
      padding: const EdgeInsets.all(1.5), // Border thickness
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFF), Color(0xFF7E7EFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today’s Goal",
                  style: TextStyle(
                    color: Color(0xFF000055),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "$_goalProgress%",
                  style: const TextStyle(
                    color: Color(0xFF000055),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Keep up the streak, $_learnerName!",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text(
                  "Completed",
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),

            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_goalProgress / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: const Color(0xFFF0F2F5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4880E6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Color(0xFF006B5B),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "On Track",
                        style: TextStyle(
                          color: Color(0xFF006B5B),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _isLoadingHome
                      ? "Loading tasks"
                      : "$_remainingTasks ${_remainingTasks == 1 ? 'task' : 'tasks'} remaining",
                  style: const TextStyle(
                    color: Color(0xFF191C1F),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String text, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
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
        if (text != 'no')
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "View all",
              style: TextStyle(
                color: Color(0xFF4F5CD1),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyMissionsGrid() {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMissionCard(
          "Daily Audio",
          _missionStatus('voiceRecordings', 3),
          Color(0xFFE2E3F7),
          "assets/images/voice.png",
          const Color(0xFFC5C6F5),
          const Color(0xFF5151EF),
          isDone: _missionDone('voiceRecordings'),
          onTap: () => _openMission(const DailyVoiceRecordingScreen()),
        ),
        _buildMissionCard(
          "Daily Video",
          _missionStatus('videoRecordings', 3),
          Color(0xFFDFF2F4),
          "assets/images/video.png",
          const Color(0xFFBCF1EC),
          const Color(0xFF006B5B),
          isDone: _missionDone('videoRecordings'),
          progress: "1/3",
          onTap: () => _openMission(const DailyVideoRecordingScreen()),
        ),
        _buildMissionCard(
          "Daily Vocabulary",
          _missionStatus('vocabulary', 2),
          Color(0xFFF3EBF3),
          "assets/images/vocabulary.png",
          const Color(0xFFF5DDEA),
          const Color(0xFF7F3858),
          isDone: _missionDone('vocabulary'),
          onTap: () => _openMission(const DailyVocabularyScreen()),
        ),
        _buildMissionCard(
          "Daily Summary",
          _missionStatus('summary', 2),
          Color(0xFFFFFFFF),
          "assets/images/summary.png",
          const Color(0xFFDCDCFC),
          const Color(0xFF5151EF),
          isDone: _missionDone('summary'),
          progress: "0/2",
          onTap: () => _openMission(const DailySummaryScreen()),
        ),
      ],
    );
  }

  Widget _buildMissionCard(
    String title,
    String status,
    Color backgroundColor,
    String iconPath,
    Color bgColor,
    Color iconColor, {
    bool isDone = false,
    String? progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F2F5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: iconColor,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF263238),
                fontSize: 13,
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
                  color: isDone ? Color(0xFF006B5B) : Color(0xFFFF8800),
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLiveClassCard() {
    final liveClass = _nextLiveClass;
    final title = liveClass?.title ?? 'No live class scheduled';
    final instructor = liveClass?.instructorName.isNotEmpty == true
        ? liveClass!.instructorName
        : 'Instructor';
    final time = liveClass == null
        ? 'Today'
        : _formatClassTime(liveClass.scheduledAt);
    final initials = instructor
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFDCDCFC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? 'LC' : initials,
              style: const TextStyle(
                color: Color(0xFF000055),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$instructor • $time",
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5151EF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              "Join",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessList() {
    final items = [
      {'label': 'BZPad', 'icon': 'assets/images/bz_pad.png'},
      {'label': 'BZ-WALLET', 'icon': 'assets/images/bzwallet.png'},
      {'label': 'BZ-Library', 'icon': 'assets/images/library.png'},
      {'label': 'BZ-Daily Mission', 'icon': 'assets/images/daily_mission.png'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (item['label'] == 'BZPad') {
                      Get.to(() => const BZPadSplashScreen());
                    } else if (item['label'] == 'BZ-WALLET') {
                      Get.to(() => const BZWalletSplashScreen());
                    } else if (item['label'] == 'BZ-Library') {
                      Get.to(() => const LibrarySplashScreen());
                    } else if (item['label'] == 'BZ-Daily Mission') {
                      Get.to(() => const DailyMissionSplashScreen());
                    }
                  },

                  child: Container(
                    width: 85,
                    height: 85,
                    //padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(item['icon']!),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  item['label']!,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlurredSection(Widget child) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: GestureDetector(
                onTap: () =>
                    Get.to(() => const SubscriberChooseProgramScreen()),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
