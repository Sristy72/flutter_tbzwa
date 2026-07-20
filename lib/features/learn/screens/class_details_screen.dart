import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/models/learner_api_models.dart';
import '../../home/services/learner_api_service.dart';

class ClassDetailsScreen extends StatefulWidget {
  final LiveClassInfo liveClass;

  const ClassDetailsScreen({super.key, required this.liveClass});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final LearnerApiService _api = LearnerApiService();
  late String _rsvp = widget.liveClass.myRsvp;
  bool _isSubmitting = false;

  LiveClassInfo get liveClass => widget.liveClass;

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
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Class Details',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Banner
            _buildTimerBanner(),
            const SizedBox(height: 30),

            // Live Status Marker
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2FBDA3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      liveClass.status == 'live'
                          ? 'Class is Live'
                          : liveClass.status.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2FBDA3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Class Title
            Center(
              child: Text(
                liveClass.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                DateFormat(
                  'EEEE, dd MMMM, hh:mm a',
                ).format(liveClass.scheduledAt),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Instructor Section
            _buildSectionTitle('INSTRUCTOR'),
            const SizedBox(height: 12),
            _buildInstructorCard(),
            const SizedBox(height: 30),

            // Description Section
            _buildSectionTitle('CLASS DESCRIPTION'),
            const SizedBox(height: 12),
            Text(
              liveClass.description.isEmpty
                  ? 'No class description available.'
                  : liveClass.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF191C1F),
                fontWeight: FontWeight.w500,
                //height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Objectives Section
            _buildSectionTitle('OBJECTIVES'),
            const SizedBox(height: 12),
            if (liveClass.objectives.isEmpty)
              _buildObjectiveItem(
                'Objectives will be shared by the instructor.',
              )
            else
              ...liveClass.objectives.map(_buildObjectiveItem),
            const SizedBox(height: 30),

            // Attendance Section
            _buildSectionTitle('WILL YOU ATTEND?'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceButton(
                    'Going',
                    Icons.check_circle_outline,
                    value: 'going',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttendanceButton(
                    'Maybe',
                    Icons.help_outline,
                    value: 'maybe',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAttendanceButton(
                    'Not Going',
                    Icons.cancel_outlined,
                    value: 'not_going',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _joinClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22A892),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Join Via Zoom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBanner() {
    final difference = liveClass.scheduledAt.difference(DateTime.now());
    final startsText = liveClass.status == 'live'
        ? 'Class is live now'
        : difference.isNegative
        ? 'Class has ended'
        : difference.inMinutes < 60
        ? 'Starts in ${difference.inMinutes} minutes'
        : difference.inHours < 24
        ? 'Starts in ${difference.inHours} hours'
        : 'Starts in ${difference.inDays} days';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFEAEDF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xFF22A892),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startsText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                "Don't forget your session today!",
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildInstructorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 2, color: Color(0xFFEAEDF1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: liveClass.instructorImageUrl?.isNotEmpty == true
                ? NetworkImage(liveClass.instructorImageUrl!)
                : const AssetImage('assets/images/default_user_avatar.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liveClass.instructorName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF191C1F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'English coach with 5+ years experience specializing in conversational fluenncy.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF22A892),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF000000),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '2.4k Students',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(Icons.circle, size: 4, color: Color(0xFF1E293B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF191C1F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton(
    String label,
    IconData icon, {
    required String value,
  }) {
    final isSelected = _rsvp == value;
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _setRsvp(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFBFF9F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF22A892)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF22A892)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setRsvp(String value) async {
    setState(() => _isSubmitting = true);
    try {
      await _api.setRsvp(liveClass.id, value);
      if (mounted) setState(() => _rsvp = value);
    } catch (error) {
      Get.snackbar(
        'Unable to update RSVP',
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _joinClass() async {
    try {
      final link = await _api.getZoomLink(liveClass.id);
      final uri = Uri.tryParse(link);
      if (uri == null ||
          link.isEmpty ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('The Zoom link is not available yet.');
      }
    } catch (error) {
      Get.snackbar(
        'Unable to join class',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
