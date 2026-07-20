import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/instructor_groups_controller.dart';
import '../models/instructor_group_model.dart';
import 'manage_group_screen.dart';

class InstructorGroupsScreen extends StatelessWidget {
  final bool showBackButton;

  const InstructorGroupsScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InstructorGroupsController>()
        ? Get.find<InstructorGroupsController>()
        : Get.put(InstructorGroupsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                onPressed: Get.back,
              )
            : null,
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
      body: RefreshIndicator(
        onRefresh: controller.refreshGroups,
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Groups",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage your assigned classes and students.",
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: controller.searchController,
                  decoration: const InputDecoration(
                    hintText: "Search groups...",
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    icon: SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter
              PopupMenuButton<String>(
                onSelected: controller.setStatus,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'all', child: Text('All Status')),
                  PopupMenuItem(value: 'active', child: Text('Active')),
                  PopupMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Obx(
                        () => Text(
                          _statusLabel(controller.selectedStatus.value),
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Obx(() {
                if (controller.isLoading.value && controller.groups.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: CircularProgressIndicator(
                        color: Color(0xFF5151EF),
                      ),
                    ),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.groups.isEmpty) {
                  return _buildMessageState(
                    controller.errorMessage.value,
                    onRetry: controller.refreshGroups,
                  );
                }
                if (controller.groups.isEmpty) {
                  final hasSearch = controller.searchController.text
                      .trim()
                      .isNotEmpty;
                  return _buildMessageState(
                    hasSearch
                        ? 'No groups match your search.'
                        : 'No groups found.',
                    onRetry: controller.refreshGroups,
                  );
                }
                return Column(
                  children: [
                    for (int i = 0; i < controller.groups.length; i++)
                      _buildGroupCard(
                        context: context,
                        controller: controller,
                        group: controller.groups[i],
                        index: i,
                      ),
                    if (controller.isLoadingMore.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(
                          color: Color(0xFF5151EF),
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String value) {
    if (value == 'active') return 'Active';
    if (value == 'inactive') return 'Inactive';
    return 'All Status';
  }

  Widget _buildMessageState(
    String message, {
    required Future<void> Function() onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            // const SizedBox(height: 12),
            // TextButton(
            //   onPressed: onRetry,
            //   child: const Text(
            //     'Retry',
            //     style: TextStyle(color: Color(0xFF5151EF)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required BuildContext context,
    required InstructorGroupsController controller,
    required InstructorGroup group,
    required int index,
  }) {
    final color = controller.groupColor(group, index);
    final isExpired = !group.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Border Highlight
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withAlpha(200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.groupLetter(group),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        group.isActive ? "Active" : "Expired",
                        style: TextStyle(
                          color: isExpired
                              ? const Color(0xFF64748B)
                              : const Color(0xFF15803D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.groupStudentsText(group),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.latestActivityText(group),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageGroupScreen(
                          groupId: group.id,
                          groupName: group.name,
                          studentCount: controller.groupStudentsText(group),
                          instructorName:
                              group.instructor?.fullName ?? "Instructor",
                          primaryColor: color,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Manage Group",
                        style: TextStyle(
                          color: Color(0xFF5151EF),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0xFF5151EF),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
