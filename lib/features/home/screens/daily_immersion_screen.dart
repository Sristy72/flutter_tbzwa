import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/learner_api_models.dart';
import '../services/learner_api_service.dart';
import 'immersion_entry_screen.dart';

class DailyImmersionScreen extends StatefulWidget {
  const DailyImmersionScreen({super.key});

  @override
  State<DailyImmersionScreen> createState() => _DailyImmersionScreenState();
}

class _DailyImmersionScreenState extends State<DailyImmersionScreen> {
  final LearnerApiService _learnerApiService = LearnerApiService();
  final TextEditingController _searchController = TextEditingController();
  List<ImmersionLogEntry> _logs = const [];
  List<ImmersionLogEntry> _allLogs = const [];
  List<ImmersionLogEntry> _todayLogs = const [];
  MissionProgress? _missionProgress;
  LearnerProfile? _profile;
  WeeklyProgress? _weeklyProgress;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImmersion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadImmersion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        _learnerApiService.getTodayImmersion(),
        _learnerApiService.getImmersionHistory(),
        _learnerApiService.getProfile(),
        _learnerApiService.getWeeklyProgress(),
      ]);
      if (!mounted) return;
      final todayImmersion = results[0] as TodayImmersion;
      final history = results[1] as List<ImmersionLogEntry>;
      setState(() {
        _todayLogs = todayImmersion.logs.isNotEmpty
            ? todayImmersion.logs
            : [if (todayImmersion.log != null) todayImmersion.log!];
        _allLogs = history;
        _logs = _selectedFilter == 'daily' ? _todayLogs : history;
        _missionProgress = todayImmersion.progress;
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
    final localCompleted = _todayLogs.length;
    return apiCompleted > localCompleted ? apiCompleted : localCompleted;
  }

  int get _target {
    final apiTarget = _missionProgress?.target ?? 3;
    return apiTarget < 3 ? 3 : apiTarget;
  }

  int get _currentStreak => _profile?.currentStreak ?? 0;
  int get _averageScore => _weeklyProgress?.average ?? 0;

  List<WeeklyDayProgress> get _weeklyDays {
    return _weeklyProgress?.currentWeekDays() ??
        WeeklyProgress(
          average: 0,
          scores: const [],
          days: const [],
        ).currentWeekDays();
  }

  List<ImmersionLogEntry> get _filteredLogs {
    if (_searchQuery.isEmpty) return _logs;
    return _logs
        .where(
          (log) =>
              log.title.toLowerCase().contains(_searchQuery) ||
              log.summary.toLowerCase().contains(_searchQuery),
        )
        .toList();
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
          "Daily English Immersion",
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
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim().toLowerCase()),
                cursorColor: const Color(0xFF374151),
                style: const TextStyle(color: Color(0xFF000000)),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  hintText: "Search immersion...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEBECEE)),
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
                            "Daily English\nImmersion",
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
                        child: const Text(
                          "Aa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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

            // Start Writing Button
            ElevatedButton(
              onPressed: () async {
                await Get.to(
                  () => ImmersionEntryScreen(learnerName: _profile?.fullName),
                );
                await _loadImmersion();
              },
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
                "Start Writing",
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
                border: Border.all(color: const Color(0xFFEBECEE)),
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
                            isActive: day.hasActivity,
                            isSpecial: day.isToday,
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
                  "$_currentStreak Days",
                  Icons.bolt,
                  const Color(0xFF26A69A),
                ),
                const SizedBox(width: 16),
                _buildSmallStatCard(
                  "Average Score",
                  "$_averageScore%",
                  Icons.percent,
                  const Color(0xFF26A69A),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    "All Immersion",
                    isActive: _selectedFilter == 'all',
                    onTap: () => _changeFilter('all'),
                  ),
                  _buildFilterChip(
                    "Daily",
                    isActive: _selectedFilter == 'daily',
                    onTap: () => _changeFilter('daily'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily List Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daily English Immersion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: Color(0xFF26A69A)),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              )
            else
              ..._filteredLogs.asMap().entries.map((entry) {
                final log = entry.value;
                return _buildListItem(
                  "${entry.key + 1}.",
                  log.title,
                  log.summary,
                  onDelete: () => _deleteImmersionLog(log),
                );
              }),

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
                  height: 48 * heightFactor.clamp(0.0, 1.0),
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
          border: Border.all(color: const Color(0xFFEBECEE)),
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

  Widget _buildFilterChip(
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildListItem(
    String number,
    String title,
    String subtitle, {
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBECEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF26A69A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          if (onDelete == null)
            const Icon(Icons.more_vert, color: Color(0xFF94A3B8))
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
    );
  }

  Future<void> _changeFilter(String filter) async {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _logs = filter == 'daily' ? _todayLogs : _allLogs;
    });
  }

  Future<void> _deleteImmersionLog(ImmersionLogEntry log) async {
    try {
      await _learnerApiService.deleteImmersionLog(log.id);
      await _loadImmersion();
    } catch (error) {
      Get.snackbar(
        'Unable to delete immersion',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
