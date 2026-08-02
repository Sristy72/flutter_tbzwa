import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/features/auth/controller/auth_controller.dart';
import 'package:flutter_tbzwa/features/profile/screens/profile_edit_screen.dart';
import 'package:get/get.dart';
import '../../subcribers_flow/subscriber_menu_drawer.dart';
import '../../home/models/learner_api_models.dart';
import '../../home/services/learner_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LearnerApiService _api = LearnerApiService();
  LearnerProfile? _profile;
  WeeklyProgress? _weekly;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final values = await Future.wait([
        _api.getProfile(),
        _api.getWeeklyProgress(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = values[0] as LearnerProfile;
        _weekly = values[1] as WeeklyProgress;
      });
    } catch (_) {
      // Keep the screen usable while a transient network error is resolved.
    }
  }

  String get _planLabel {
    final value = _profile?.plan ?? 'none';
    if (value == 'none') return 'NO ACTIVE PLAN';
    return value
        .replaceAll('_plus_plus', '++')
        .replaceAll('_plus', '+')
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: const Icon(
                              Icons.menu,
                              color: Color(0xFF1E293B),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildHeader(),
                  ],
                ),
              ),
              Divider(color: Color(0xFFD1D1D1)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: _buildProfileHeader(),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Performance Analytics'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: _buildAnalyticsCard(
                        'Current Streak',
                        '${_profile?.currentStreak ?? 0} Days',
                        Icons.bolt_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: _buildAnalyticsCard(
                        'Average Score',
                        '${_weekly?.average ?? 0}%',
                        Icons.percent_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Weekly Consistency'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: _buildConsistencyChart(),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Quick Access'),
              const SizedBox(height: 12),
              _buildAccessItem(
                'BZPad',
                'Your Personal Notebook',
                Icons.description_outlined,
              ),
              _buildAccessItem(
                'BZ-Wallet',
                'Your Personal Wallet',
                Icons.account_balance_wallet_outlined,
              ),
              _buildAccessItem(
                'BZ-Library',
                'Your Personal Dictionary',
                Icons.library_books_outlined,
              ),
              _buildAccessItem(
                'BZ-Daily Mission',
                'Your Personal Progress',
                Icons.insights_rounded,
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Settings'),
              const SizedBox(height: 12),
              _buildSettingsItem('Language', Icons.language_rounded),
              _buildSettingsItem('Buy Plan', Icons.card_membership_rounded),
              _buildSettingsItem('Change Password', Icons.lock_outline),

              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: _buildLogoutButton('Delete Account'),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: GestureDetector(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.find<AuthController>().logout();
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: _buildLogoutButton('Logout'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: _profile?.profileImageUrl?.isNotEmpty == true
                    ? NetworkImage(_profile!.profileImageUrl!)
                    : const AssetImage('assets/images/default_user_avatar.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.fullName.isNotEmpty == true
                          ? _profile!.fullName
                          : 'Kathy Onana',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'User ID : ${_profile?.userId.isNotEmpty == true ? _profile!.userId : 'BZ234567'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: IconButton(
                  onPressed: () async {
                    final updated = await Get.to<LearnerProfile>(
                      () => ProfileEditScreen(profile: _profile),
                    );
                    if (updated != null && mounted) {
                      setState(() => _profile = updated);
                    }
                  },
                  icon: Icon(Icons.mode_edit_outlined, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFBFF9F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _planLabel,
              style: const TextStyle(
                color: Color(0xFF22A892),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF22A892), size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyChart() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final scores = _weekly?.scores ?? const <int>[];
    final values = List<double>.generate(
      7,
      (index) =>
          index < scores.length ? (scores[index] / 100).clamp(0.0, 1.0) : 0.0,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            children: [
              Container(
                width: 32,
                height: 60 * values[index],
                decoration: BoxDecoration(
                  color: values[index] > 0.8
                      ? const Color(0xFFBFF9F0)
                      : values[index] < 0.2
                      ? const Color(0xFF146456)
                      : const Color(
                          0xFF30EDCD,
                        ).withOpacity(index % 2 == 0 ? 0.3 : 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                days[index],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAccessItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFDFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF22A892), size: 22),
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
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAFDFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF22A892), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Builder(
          //   builder: (context) => GestureDetector(
          //     onTap: () => Scaffold.of(context).openDrawer(),
          //     child: const Icon(Icons.menu, color: Color(0xFF1E293B), size: 24),
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
          const SizedBox(width: 24), // balance spacer
        ],
      ),
    );
  }

  Widget _buildLogoutButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEDED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            text == 'Logout' ? Icons.logout_rounded : null,
            color: Color(0xFFE24B4A),
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFFE24B4A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
