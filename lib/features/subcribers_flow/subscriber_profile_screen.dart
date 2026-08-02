import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/controller/auth_controller.dart';
import '../home/models/learner_api_models.dart';
import '../home/services/learner_api_service.dart';
import 'subscriber_choose_program_screen.dart';
import 'subscriber_menu_drawer.dart';

class SubscriberProfileScreen extends StatefulWidget {
  const SubscriberProfileScreen({super.key});

  @override
  State<SubscriberProfileScreen> createState() =>
      _SubscriberProfileScreenState();
}

class _SubscriberProfileScreenState extends State<SubscriberProfileScreen> {
  final LearnerApiService _api = LearnerApiService();
  LearnerProfile? _profile;
  LearnerProgressSnapshot? _progress;
  DailyMissionSummary? _missions;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final values = await Future.wait<dynamic>([
        _api.getProfile(),
        _api.getProgressSnapshot(),
        _api.getDailyMissions(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = values[0] as LearnerProfile;
        _progress = values[1] as LearnerProgressSnapshot;
        _missions = values[2] as DailyMissionSummary;
      });
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Profile',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String get _fullName =>
      _profile?.fullName.trim().isNotEmpty == true ? _profile!.fullName : '';

  String get _email =>
      _profile?.email.trim().isNotEmpty == true ? _profile!.email : '';

  String get _userId =>
      _profile?.userId.trim().isNotEmpty == true ? _profile!.userId : '';

  String get _planLabel => _formatPlan(_profile?.plan ?? 'none');

  String get _subscriptionLabel {
    final status = _profile?.subscriptionStatus ?? '';
    if (_planLabel.isEmpty) return status;
    return '$_planLabel - ${_capitalize(status)}';
  }

  String get _memberSince => _formatMonthYear(_profile?.memberSince);

  double _missionRatio(String key) {
    final mission = _missions?.missions[key];
    if (mission == null || mission.target == 0) return 0;
    return (mission.completed / mission.target).clamp(0.0, 1.0);
  }

  String _missionLabel(String key) {
    final mission = _missions?.missions[key];
    if (mission == null) return '0/0';
    return '${mission.completed}/${mission.target}';
  }

  Widget _buildNetworkAvatar(double radius, String? url) {
    final size = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8EAF0),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? SizedBox(width: size, height: size)
            : Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
              ),
      ),
    );
  }

  String _formatPlan(String value) {
    if (value == 'none' || value.isEmpty) return '';
    if (value == 'immersion_plus_plus') return 'IMMERSION++';
    return value.replaceAll('_', ' ').toUpperCase();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return '';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatMonthYear(DateTime? date) {
    if (date == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Color(0xFF000000), fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF000000), fontSize: 16),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: _isLoggingOut ? null : _logout,
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFE00000)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Get.back();
    if (!mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      await Get.find<AuthController>().logout();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      Get.snackbar(
        'Logout',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Main Content (Blurred) ──────────────────────────────────────────
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  const Divider(color: Color(0xFFD1D1D1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildProfileInfoCard(),
                        const SizedBox(height: 20),
                        _buildStatsRow(),
                        const SizedBox(height: 24),
                        _buildProgressBreakdown(),
                        const SizedBox(height: 28),
                        _buildQuickActions(),
                        const SizedBox(height: 28),
                        _buildSubscriptionCard(),
                        const SizedBox(height: 20),
                        _buildSettingsTile(),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Blur Overlay ──────────────────────────────────────────────────
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: GestureDetector(
                  onTap: () =>
                      Get.to(() => const SubscriberChooseProgramScreen()),
                  child: Container(color: Colors.black.withValues(alpha: 0.01)),
                ),
              ),
            ),

            // ─── Unblurred Header (AppBar + Profile Card) ──────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFFF7F8FC),
                child: Column(
                  children: [
                    _buildAppBar(),
                    const Divider(color: Color(0xFFD1D1D1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildProfileInfoCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Builder(
          //   builder: (context) => GestureDetector(
          //     onTap: () => Scaffold.of(context).openDrawer(),
          //     child: const Icon(Icons.menu, color: Color(0xFF1E293B), size: 28),
          //   ),
          // ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: "TALK/"),
                TextSpan(text: "'BZ/"),
              ],
            ),
          ),
          const SizedBox(width: 28), // balance
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFE9E9E9), width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNetworkAvatar(40, _profile?.profileImageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF686868),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A63E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/crown.png',
                            width: 12,
                            height: 12,
                          ),
                          Text(
                            ' $_planLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Color(0xFFDEDEDE)),
          const SizedBox(height: 12),
          _buildInfoRow('User ID', _userId),
          const SizedBox(height: 12),
          Divider(color: Color(0xFFDEDEDE)),
          const SizedBox(height: 12),
          _buildInfoRow('Member Since', _memberSince),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF686868),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          'Lessons\nCompleted',
          '${_progress?.completedLessons ?? 0}',
          'assets/images/medal-star.png',
          const Color(0xFF5456E7),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Daily\nStreaks',
          '${_profile?.currentStreak ?? 0} days',
          'assets/images/daily_streak.png',
          const Color(0xFF5456E7),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Total\nProgress',
          '${_progress?.totalProgress ?? 0}%',
          'assets/images/symbols_crown.png',
          const Color(0xFF5456E7),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String image, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFEAEAEA)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
          child: Column(
            children: [
              Image.asset(image, width: 26, height: 26),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF49454F),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBreakdown() {
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
          const Text(
            'Progress Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            'Voice Recording',
            _missionRatio('voiceRecordings'),
            const Color(0xFF00C853),
            _missionLabel('voiceRecordings'),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Video Recording',
            _missionRatio('videoRecordings'),
            const Color(0xFFFB8C00),
            _missionLabel('videoRecordings'),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Vocabulary',
            _missionRatio('vocabulary'),
            const Color(0xFFFFD600),
            _missionLabel('vocabulary'),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Reading',
            _missionRatio('summary'),
            const Color(0xFF4A82E7),
            _missionLabel('summary'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double progress,
    Color color,
    String value,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF878787),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF878787),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          'BZ-WALLET',
          'assets/images/wallet.png',
          const Color(0xFFD2D3F6),
        ),
        _buildActionItem(
          'BZ-Daily Mission',
          'assets/images/note.png',
          const Color(0xFFCBF2EF),
        ),
        _buildActionItem(
          'BZ-Library',
          'assets/images/bz_library.png',
          const Color(0xFFF5E3EE),
        ),
        _buildActionItem(
          'BZPad',
          'assets/images/pad.png',
          const Color(0xFFAAFFB4),
        ),
      ],
    );
  }

  Widget _buildActionItem(String label, String image, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Image.asset(image, width: 24, height: 24),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subscriptionLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF878787),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/glyphs-poly_crown-1.png',
                width: 24,
                height: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextButton(
              onPressed: () =>
                  Get.to(() => const SubscriberChooseProgramScreen()),
              child: const Text(
                'Manage Subscription',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.settings_outlined, color: Color(0xFF1E293B), size: 24),
          SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE00000)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton.icon(
        onPressed: _isLoggingOut ? null : _showLogoutDialog,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE00000),
                ),
              )
            : const Icon(Icons.logout, color: Color(0xFFE00000)),
        label: Text(
          _isLoggingOut ? 'Logging out...' : 'Logout',
          style: const TextStyle(
            color: Color(0xFFE00000),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
