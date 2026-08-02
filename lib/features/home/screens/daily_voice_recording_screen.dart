import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/learner_api_models.dart';
import '../models/voice_recording_model.dart';
import '../services/learner_api_service.dart';
import '../services/voice_recording_api_service.dart';
import 'audio_recording_screen.dart';

class DailyVoiceRecordingScreen extends StatefulWidget {
  const DailyVoiceRecordingScreen({super.key});

  @override
  State<DailyVoiceRecordingScreen> createState() =>
      _DailyVoiceRecordingScreenState();
}

class _DailyVoiceRecordingScreenState extends State<DailyVoiceRecordingScreen> {
  final VoiceRecordingApiService _recordingApiService =
      VoiceRecordingApiService();
  final LearnerApiService _learnerApiService = LearnerApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<VoiceRecordingModel> _recordings = const [];
  MissionProgress? _missionProgress;
  LearnerProfile? _profile;
  WeeklyProgress? _weeklyProgress;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  String? _playingRecordingId;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingRecordingId = null);
    });
    _loadRecordings();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadRecordings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        _recordingApiService.getRecordingsForDate(DateTime.now()),
        _learnerApiService.getDailyMissions(),
        _learnerApiService.getProfile(),
        _learnerApiService.getWeeklyProgress(),
      ]);
      if (!mounted) return;
      final missions = results[1] as DailyMissionSummary;
      setState(() {
        _recordings = results[0] as List<VoiceRecordingModel>;
        _missionProgress = missions.missions['voiceRecordings'];
        _profile = results[2] as LearnerProfile;
        _weeklyProgress = results[3] as WeeklyProgress;
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

  int get _completed {
    final apiCompleted = _missionProgress?.completed ?? 0;
    return apiCompleted > _recordings.length
        ? apiCompleted
        : _recordings.length;
  }

  int get _target {
    final apiTarget = _missionProgress?.target ?? 3;
    return apiTarget < 3 ? 3 : apiTarget;
  }

  int get _currentStreak => _profile?.currentStreak ?? 0;
  int get _averageScore => _weeklyProgress?.average ?? 0;

  Future<void> _openRecorder() async {
    if (_completed >= 3) {
      Get.snackbar(
        'Daily Voice',
        "You've reached today's 3 audio recordings limit.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await Get.to(() => const AudioRecordingScreen());
    await _loadRecordings();
  }

  List<WeeklyDayProgress> get _weeklyDays {
    return _weeklyProgress?.currentWeekDays() ??
        WeeklyProgress(
          average: 0,
          scores: const [],
          days: const [],
        ).currentWeekDays();
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
          "Daily Voice Recording",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: TextField(
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim().toLowerCase()),
                cursorColor: const Color(0xFF374151),
                style: const TextStyle(color: Color(0xFF000000)),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  hintText: "Search recordings...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Today's Audio Progress Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFEBECEE)),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "MISSION ACTIVE",
                              style: TextStyle(
                                color: Color(0xFF151918),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Today's Audio\nProgress",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF374151),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF26A69A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progress to Mastery",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "$_completed/$_target",
                        style: const TextStyle(
                          color: Color(0xFF374151),
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Start Audio Recording Button
            ElevatedButton(
              onPressed: _openRecorder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Start Audio Recording",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Consistency Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFFEBECEE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Consistency",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weeklyDays
                        .map(
                          (day) => _buildDayItem(
                            day.dayLabel,
                            day.score / 100,
                            isActive: day.hasActivity && day.score > 0,
                            isSpecial: day.isToday && day.score >= 100,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                _buildSmallStatCard(
                  "Current Streak",
                  "$_currentStreak ${_currentStreak == 1 ? 'Day' : 'Days'}",
                  Icons.bolt,
                  Color(0xFF26A69A),
                ),
                const SizedBox(width: 16),
                _buildSmallStatCard(
                  "Average Score",
                  "$_averageScore%",
                  Icons.percent,
                  Color(0xFF26A69A),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All Recordings", 'all'),
                  _buildFilterChip("Morning Drill", 'morning'),
                  _buildFilterChip("Afternoon Dr.", 'afternoon'),
                  _buildFilterChip("Evening", 'evening'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Voice Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daily Voice",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
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
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              _buildErrorSection()
            else
              ..._buildDailyVoiceItems(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(
    String day,
    double heightFactor, {
    bool isActive = false,
    bool isSpecial = false,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 48,
          decoration: BoxDecoration(
            color: isSpecial
                ? const Color(0xFF26A69A)
                : const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.bottomCenter,
          child: isActive
              ? Container(
                  height: 48 * heightFactor,
                  decoration: BoxDecoration(
                    color: isSpecial
                        ? const Color(0xFF26A69A)
                        : const Color(0xFF26A69A).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFEBECEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isActive = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF26A69A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFF1F5F9),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingItem(
    String title,
    String subtitle,
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF26A69A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFEBECEE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFE0F2F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF26A69A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete == null)
              Icon(
                Icons.more_vert,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              )
            else
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                color: Colors.white,
                icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDailyVoiceItems() {
    const slots = ['morning', 'afternoon', 'evening'];
    final widgets = <Widget>[];

    for (final slot in slots) {
      if (_selectedFilter != 'all' && _selectedFilter != slot) continue;
      final slotRecordings = _recordings.where((item) {
        final matchesSlot = item.timeSlot == slot;
        final matchesSearch =
            _searchQuery.isEmpty ||
            item.label.toLowerCase().contains(_searchQuery) ||
            item.slotTitle.toLowerCase().contains(_searchQuery);
        return matchesSlot && matchesSearch;
      }).toList();

      if (slotRecordings.isEmpty) {
        final title = _slotTitle(slot);
        if (_searchQuery.isNotEmpty &&
            !title.toLowerCase().contains(_searchQuery)) {
          continue;
        }
        widgets.add(
          _buildRecordingItem(
            title,
            _slotPrompt(slot),
            Icons.mic,
            isActive: true,
            onTap: _openRecorder,
          ),
        );
      } else {
        for (final recording in slotRecordings) {
          widgets.add(
            _buildRecordingItem(
              recording.slotTitle,
              '${recording.label}\n${recording.durationLabel}',
              _playingRecordingId == recording.id
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              onTap: () => _playRecording(recording),
              onDelete: () => _deleteRecording(recording),
            ),
          );
        }
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No recordings found.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ),
        ),
      );
    }
    return widgets;
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
      await _loadRecordings();
    } catch (error) {
      Get.snackbar(
        'Unable to delete recording',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _slotTitle(String slot) {
    switch (slot) {
      case 'morning':
        return 'Morning Drill';
      case 'afternoon':
        return 'Afternoon Fluency';
      default:
        return 'Evening Reflection';
    }
  }

  String _slotPrompt(String slot) {
    switch (slot) {
      case 'morning':
        return 'Vowel pronunciation &\ntone check';
      case 'afternoon':
        return '3-minute casual\nconversation';
      default:
        return 'Summarize your day in target\nlanguage';
    }
  }

  Widget _buildErrorSection() {
    return Center(
      child: Column(
        children: [
          Text(
            _errorMessage ?? 'Unable to load recordings.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          TextButton(
            onPressed: _loadRecordings,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
