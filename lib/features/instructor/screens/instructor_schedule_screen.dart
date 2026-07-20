import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/instructor_home_controller.dart';
import '../models/instructor_home_model.dart';

class InstructorScheduleScreen extends StatelessWidget {
  const InstructorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InstructorHomeController>()
        ? Get.find<InstructorHomeController>()
        : Get.put(InstructorHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: Get.back,
        ),
        title: const Text(
          "Schedule",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => RefreshIndicator(
            onRefresh: controller.refreshHome,
            color: const Color(0xFF5151EF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.isLoading.value && controller.data == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5151EF),
                        ),
                      ),
                    )
                  else if (controller.errorMessage.value.isNotEmpty &&
                      controller.data == null)
                    _buildErrorState(controller)
                  else ...[
                    _buildSection(
                      title: "Today's Classes",
                      classes: controller.todayClasses,
                      emptyMessage: "No classes scheduled for today.",
                      controller: controller,
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      title: "Upcoming Sessions",
                      classes: controller.upcomingSessions,
                      emptyMessage: "No upcoming sessions found.",
                      controller: controller,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<InstructorHomeClass> classes,
    required String emptyMessage,
    required InstructorHomeController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        if (classes.isEmpty)
          _buildEmptyState(emptyMessage)
        else
          Column(
            children: [
              for (int i = 0; i < classes.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _buildClassCard(classes[i], controller),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildClassCard(
    InstructorHomeClass liveClass,
    InstructorHomeController controller,
  ) {
    final status = liveClass.status.trim().isEmpty
        ? 'scheduled'
        : liveClass.status.trim();
    final canStart = status == 'scheduled' || status == 'live';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: Color(0xFF5151EF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveClass.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.classSubtitle(liveClass),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, _dateText(liveClass)),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            controller.classTimeRange(liveClass),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.info_outline, _statusText(status)),
          if (canStart) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isStartingClass(liveClass.id)
                      ? null
                      : () => controller.startClass(liveClass),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEDFF),
                    foregroundColor: const Color(0xFF5151EF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(status == 'live' ? "Join Class" : "Start Class"),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      ),
    );
  }

  Widget _buildErrorState(InstructorHomeController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.errorMessage.value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.loadHome,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF5151EF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  String _dateText(InstructorHomeClass liveClass) {
    final scheduledAt = liveClass.scheduledAt;
    if (scheduledAt == null) return 'Date unavailable';
    return DateFormat('EEE, MMM d, yyyy').format(scheduledAt);
  }

  String _statusText(String status) {
    if (status.isEmpty) return 'Scheduled';
    return status[0].toUpperCase() + status.substring(1);
  }
}
