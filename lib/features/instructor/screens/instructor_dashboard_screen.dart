import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/assest_const.dart';
import '../../../core/utils/app_svg.dart';
import '../controllers/instructor_home_controller.dart';
import '../models/instructor_home_model.dart';
import '../widgets/create_room_dialog.dart';
import 'manage_group_screen.dart';

class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InstructorHomeController>()
        ? Get.find<InstructorHomeController>()
        : Get.put(InstructorHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: Obx(
        () => Column(
          children: [
            _buildHeader(controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshHome,
                color: const Color(0xFF5151EF),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeText(controller),
                      const SizedBox(height: 24),
                      if (controller.errorMessage.value.isNotEmpty &&
                          controller.data == null)
                        _buildErrorState(controller)
                      else ...[
                        _buildActionButtons(context, controller),
                        const SizedBox(height: 10),
                        _buildStatGrid(controller),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          "Today's Classes",
                          "View Schedule",
                          controller.openSchedule,
                        ),
                        const SizedBox(height: 16),
                        _buildTodaysClasses(controller),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          "Assigned Groups",
                          "View All",
                          controller.openGroups,
                        ),
                        const SizedBox(height: 16),
                        _buildAssignedGroups(controller),
                        const SizedBox(height: 32),
                        _buildUpcomingSessions(controller),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(InstructorHomeController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5151EF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bonjour,",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        controller.instructorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.openNotifications,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SOLDE PRINCIPAL",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          controller.balanceText,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "ID: ${controller.instructorId}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(InstructorHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, ${controller.instructorFirstName}!",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Here's what's happening with your classes today.",
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    InstructorHomeController controller,
  ) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CreateRoomDialog(controller: controller),
            );
          },
          icon: AppSvg(
            asset: AssetsConstants.images.roomIcon,
            height: 20,
            width: 20,
          ),
          label: const Text("Create Room"),

          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF475569),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: controller.startNextClass,
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text("Start Class"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF5151EF),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(InstructorHomeController controller) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          Icons.people_outline,
          const Color(0xFF5151EF),
          "Total Students",
          controller.totalStudentsText,
        ),
        _buildStatCard(
          Icons.groups_outlined,
          const Color(0xFF10B981),
          "Active Groups",
          controller.activeGroupsText,
        ),
        _buildStatCard(
          Icons.videocam_outlined,
          const Color(0xFF6366F1),
          "Today's Classes",
          controller.todayClassesText,
        ),
        _buildStatCard(
          Icons.chat_bubble_outline,
          const Color(0xFFF59E0B),
          "Pending Messages",
          controller.pendingMessagesText,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback? onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5151EF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF5151EF))),
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

  Widget _buildTodaysClasses(InstructorHomeController controller) {
    if (controller.isLoading.value && controller.data == null) {
      return _buildLoadingState();
    }
    if (controller.todayClasses.isEmpty) {
      return _buildEmptyState("No classes scheduled for today.");
    }

    return Column(
      children: controller.todayClasses.asMap().entries.map((entry) {
        final index = entry.key;
        final liveClass = entry.value;
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 12),
            _buildClassCard(liveClass, controller),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildClassCard(
    InstructorHomeClass liveClass,
    InstructorHomeController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          Row(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveClass.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AppSvg(
                      asset: AssetsConstants.images.clock,
                      height: 14,
                      width: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.classTimeRange(liveClass),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.startClass(liveClass),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEDFF),
                foregroundColor: const Color(0xFF5151EF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Join Class"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedGroups(InstructorHomeController controller) {
    if (controller.isLoading.value && controller.data == null) {
      return _buildLoadingState();
    }
    if (controller.assignedGroups.isEmpty) {
      return _buildEmptyState("No assigned groups found.");
    }

    return Column(
      children: controller.assignedGroups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return Column(
          children: [
            if (index > 0) const SizedBox(height: 12),
            _buildGroupCard(
              controller.groupLetter(group),
              controller.groupColor(group, index),
              group.name,
              controller.groupStudentsText(group),
              onTap: () {
                Get.to(
                  () => ManageGroupScreen(
                    groupName: group.name,
                    studentCount: controller.groupStudentsText(group),
                    instructorName: controller.instructorName,
                    primaryColor: controller.groupColor(group, index),
                  ),
                );
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGroupCard(
    String letter,
    Color color,
    String title,
    String students, {
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  students,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Active",
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "View \u276F",
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(InstructorHomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Sessions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          if (controller.isLoading.value && controller.data == null)
            _buildLoadingState()
          else if (controller.upcomingSessions.isEmpty)
            _buildEmptyState("No upcoming sessions found.")
          else
            ...controller.upcomingSessions.asMap().entries.map((entry) {
              final index = entry.key;
              final liveClass = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                    ),
                  _buildSessionRow(
                    controller.sessionDateLabel(liveClass),
                    liveClass.title,
                    liveClass.groupName,
                    controller.classTimeRange(liveClass).split(' - ').first,
                    liveClass.status == 'scheduled',
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSessionRow(
    String date,
    String title,
    String subject,
    String time,
    bool isActive,
  ) {
    Color textColor = isActive
        ? const Color(0xFF1F2937)
        : const Color(0xFF9CA3AF);
    Color subTextColor = isActive
        ? const Color(0xFF6B7280)
        : const Color(0xFFD1D5DB);
    Color timeColor = isActive
        ? const Color(0xFF5151EF)
        : const Color(0xFFA5B4FC);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 16,
                color: isActive
                    ? const Color(0xFF5151EF)
                    : const Color(0xFFC7D2FE),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject,
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: timeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
