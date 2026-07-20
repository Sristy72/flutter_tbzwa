import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/models/learner_api_models.dart';
import '../../home/services/learner_api_service.dart';

class TodayProgressScreen extends StatefulWidget {
  const TodayProgressScreen({super.key});

  @override
  State<TodayProgressScreen> createState() => _TodayProgressScreenState();
}

class _TodayProgressScreenState extends State<TodayProgressScreen> {
  final LearnerApiService _api = LearnerApiService();
  DailyMissionSummary? _missions;
  WeeklyProgress? _weeklyProgress;
  LearnerProfile? _profile;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final values = await Future.wait<dynamic>([
        _api.getDailyMissions(),
        _api.getWeeklyProgress(),
        _api.getProfile(),
      ]);
      if (!mounted) return;
      setState(() {
        _missions = values[0] as DailyMissionSummary;
        _weeklyProgress = values[1] as WeeklyProgress;
        _profile = values[2] as LearnerProfile;
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _dailyScore => (_missions?.overallProgress ?? 0).clamp(0, 100);
  int get _averageScore => (_weeklyProgress?.average ?? 0).clamp(0, 100);
  int get _currentStreak => _profile?.currentStreak ?? 0;

  List<WeeklyDayProgress> get _weeklyDays {
    return _weeklyProgress?.currentWeekDays() ??
        WeeklyProgress(
          average: 0,
          scores: const [],
          days: const [],
        ).currentWeekDays();
  }

  String get _firstName {
    final name = _profile?.fullName.trim() ?? '';
    return name.isEmpty ? 'Learner' : name.split(RegExp(r'\s+')).first;
  }

  int get _weeklyTrend {
    final scores = _weeklyDays.map((day) => day.score).toList();
    if (scores.length < 2) return 0;
    return scores.last - scores.first;
  }

  String _engagementLabel(int score) {
    if (score >= 85) return 'Highly Engaged';
    if (score >= 50) return 'Moderately Engaged';
    if (score > 0) return 'Getting Started';
    return 'Not Started';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          "Today's Progress",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: LinearProgressIndicator(color: Color(0xFF26A69A)),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadProgress,
                      child: const Text("Try again"),
                    ),
                  ],
                ),
              ),
            _buildCircularProgress(),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF2EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_engagementLabel(_dailyScore)} ($_dailyScore%)",
                style: const TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildAchievementCard(),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildActivityBreakdown(),
              ),
            ),
            const SizedBox(height: 40),
            _buildWeeklyActivity(),
            const SizedBox(height: 40),
            _buildEvolutionChart(),
            const SizedBox(height: 40),
            _buildStatsCards(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDFF2EE),
                foregroundColor: const Color(0xFF006B5B),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Complete Today's Tasks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    final score = _dailyScore;
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 15,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF26A69A),
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$score%",
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Text(
                  "DAILY SCORE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9CA4B1),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard() {
    final remaining =
        ((_missions?.totalCount ?? 0) - (_missions?.completedCount ?? 0)).clamp(
          0,
          100,
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFCCE8E7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            "Nice Progress $_firstName!",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining == 0
                ? "All daily missions are complete."
                : "$remaining progress ${remaining == 1 ? 'is' : 'are'} still remaining.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF000000),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    final voice = _mission('voiceRecordings', 3);
    final video = _mission('videoRecordings', 3);
    final vocabulary = _mission('vocabulary', 2);
    final summary = _mission('summary', 2);
    final immersion = _mission('immersion', 3);
    final bzpad = _mission('bzpad', 1);
    final switchEnglish = _mission('switchToEnglish', 1);
    final activities = [
      _activity('Daily Voice', voice, Icons.mic_none_rounded),
      _activity('Daily Video', video, Icons.video_camera_back_outlined),
      _activity('Daily Vocabulary', vocabulary, Icons.text_fields_rounded),
      _activity('Daily Summary', summary, Icons.assignment_outlined),
      _activity(
        'Daily English Immersion',
        immersion,
        Icons.headphones_outlined,
      ),
      _activity(
        'Daily BZPad',
        bzpad,
        Icons.edit_note_rounded,
        isReminder: true,
      ),
      _activity(
        'Switch Everything In English',
        switchEnglish,
        Icons.star_border_rounded,
        isReminder: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Activity Breakdown",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "Total 100%",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF686F7C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...activities.map(
          (act) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEAFDFA),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          act['icon'] as IconData,
                          size: 18,
                          color: act['color'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      act['label'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      act['value'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (act['isReminder'] as bool)
                            ? const Color(0xFF26A69A)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                if (!(act['isReminder'] as bool)) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: act['progress'] as double,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        act['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  MissionProgress _mission(String key, int fallbackTarget) {
    return _missions?.missions[key] ??
        MissionProgress(completed: 0, target: fallbackTarget);
  }

  Map<String, Object> _activity(
    String label,
    MissionProgress mission,
    IconData icon, {
    bool isReminder = false,
  }) {
    final progress = mission.target == 0
        ? 0.0
        : (mission.completed / mission.target).clamp(0.0, 1.0);
    final isComplete = mission.completed >= mission.target;
    return {
      'label': label,
      'progress': progress,
      'value': isReminder
          ? (isComplete ? 'COMPLETE' : 'REMINDER')
          : '${mission.completed}/${mission.target}',
      'icon': icon,
      'color': isComplete || progress > 0
          ? const Color(0xFF26A69A)
          : const Color(0xFFD1D5DB),
      'isReminder': isReminder,
    };
  }

  Widget _buildWeeklyActivity() {
    final days = _weeklyDays
        .map(
          (day) => {
            'day': day.dayLabel,
            'progress': (day.score / 100).clamp(0.0, 1.0),
          },
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Activity",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days
              .map(
                (d) => Column(
                  children: [
                    Container(
                      width: 32,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        heightFactor: d['progress'] as double,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF30EDCD), Color(0xFF26A69A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d['day'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEvolutionChart() {
    final trend = _weeklyTrend;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overall Evolution",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Text(
                    "Statistical progress since Day 1",
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${trend >= 0 ? '+' : ''}$trend%",
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _EvolutionPainter(
                _weeklyDays.map((day) => day.score).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Day 1",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Current",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildStatItem(
          "Current Streak",
          "$_currentStreak ${_currentStreak == 1 ? 'Day' : 'Days'}",
          Icons.auto_graph_rounded,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          "Average Score",
          "$_averageScore%",
          Icons.percent_rounded,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC7C8CF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFEAFDFA),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: const Color(0xFF26A69A), size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionPainter extends CustomPainter {
  final List<int> scores;

  const _EvolutionPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF26A69A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = const Color(0xFF26A69A).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final values = scores.isEmpty ? const [0, 0] : scores;
    final step = values.length == 1
        ? size.width
        : size.width / (values.length - 1);
    Offset pointFor(int index, int score) {
      final x = values.length == 1 ? size.width : step * index;
      final y = size.height * (1 - (score.clamp(0, 100) / 100));
      return Offset(x, y.clamp(0.0, size.height));
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = pointFor(i, values[i]);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF26A69A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pointFor(0, values.first), 4, pointPaint);
    canvas.drawCircle(pointFor(values.length - 1, values.last), 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter oldDelegate) {
    return oldDelegate.scores.join(',') != scores.join(',');
  }
}
