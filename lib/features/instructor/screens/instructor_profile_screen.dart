import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/instructor_profile_controller.dart';
import '../models/instructor_profile_model.dart';
import 'instructor_edit_profile_screen.dart';

class InstructorProfileScreen extends StatelessWidget {
  const InstructorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InstructorProfileController>()
        ? Get.find<InstructorProfileController>()
        : Get.put(InstructorProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "TALK/'BZ/",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (controller.isLoading.value &&
                    controller.profile.value == null)
                  const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5151EF),
                      ),
                    ),
                  )
                else if (controller.errorMessage.value.isNotEmpty &&
                    controller.profile.value == null)
                  _buildErrorState(controller)
                else ...[
                  _buildProfileCard(context, controller),
                  const SizedBox(height: 20),
                  _buildAssignedGroupsCard(controller),
                  const SizedBox(height: 20),
                  _buildSettingsCard(controller),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(InstructorProfileController controller) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.refreshProfile,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    InstructorProfileController controller,
  ) {
    final profile = controller.profile.value;
    final avatar = controller.avatarImageProvider();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5151EF), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFE5E7EB),
                              backgroundImage: avatar,
                              child: avatar == null
                                  ? Text(
                                      profile?.initials ?? 'I',
                                      style: const TextStyle(
                                        color: Color(0xFF4B5563),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6366F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InstructorEditProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Color(0xFF4B5563),
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile?.displayName ?? 'Instructor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Instructor",
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.displayBio ?? 'No bio added yet.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile?.displayEmail ?? 'Email unavailable',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile?.displayPhone ?? 'Phone unavailable',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
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

  Widget _buildAssignedGroupsCard(InstructorProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assigned Groups",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          if (controller.isGroupsLoading.value)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF5151EF)),
            )
          else if (controller.groupsErrorMessage.value.isNotEmpty)
            Column(
              children: [
                Text(
                  controller.groupsErrorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.refreshProfile,
                  child: const Text("Retry"),
                ),
              ],
            )
          else if (controller.groups.isEmpty)
            const Text(
              "No assigned groups yet.",
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            )
          else
            ...controller.groups.asMap().entries.map((entry) {
              final group = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == controller.groups.length - 1 ? 0 : 16,
                ),
                child: _buildGroupItem(
                  group: group,
                  students: controller.groupStudentsText(group),
                  color: controller.groupColor(group, entry.key),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildGroupItem({
    required InstructorProfileGroup group,
    required String students,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              group.letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  students,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(InstructorProfileController controller) {
    final notificationsEnabled =
        controller.profile.value?.notificationsEnabled ?? true;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: notificationsEnabled,
                onChanged: controller.isUpdatingNotifications.value
                    ? null
                    : controller.updateNotifications,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF5151EF),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: controller.showPrivacySecurityUnavailable,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 18,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Privacy & Security",
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: InkWell(
              onTap: controller.isLoggingOut.value ? null : controller.logout,
              child: Text(
                controller.isLoggingOut.value ? "Logging Out..." : "Log Out",
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
