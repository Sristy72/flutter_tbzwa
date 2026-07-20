import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/instructor_messages_controller.dart';
import 'instructor_message_chat_screen.dart';

class InstructorMessagesScreen extends StatelessWidget {
  const InstructorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InstructorMessagesController>()
        ? Get.find<InstructorMessagesController>()
        : Get.put(InstructorMessagesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // User requested no back arrow
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF6B7280),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF5456E7),
        onRefresh: controller.refreshConversations,
        child: SingleChildScrollView(
          controller: controller.conversationScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 150,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Messages",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => _buildConversationList(controller)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(InstructorMessagesController controller) {
    if (controller.isInitialLoading.value && controller.conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: Color(0xFF5456E7)),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty &&
        controller.conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              TextButton(
                onPressed: controller.refreshConversations,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Text(
            "No conversations yet.",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final conversation in controller.conversations)
          conversation.isGroup
              ? _buildGroupMessageCard(
                  name: conversation.title,
                  message: conversation.preview,
                  time: controller.conversationTime(conversation),
                  avatarUrls: conversation.avatarUrls,
                  countText: controller.groupCountText(conversation),
                  unreadCount: conversation.unreadCount,
                  initial: controller.initialFor(conversation.title),
                  onTap: () {
                    controller.openConversation(conversation);
                    Get.to(
                      () => InstructorMessageChatScreen(
                        conversationId: conversation.id,
                      ),
                    );
                  },
                )
              : _buildMessageCard(
                  name: conversation.title,
                  message: conversation.preview,
                  time: controller.conversationTime(conversation),
                  imagePath: conversation.avatarUrl ?? '',
                  initial: controller.initialFor(conversation.title),
                  unreadCount: conversation.unreadCount,
                  onTap: () {
                    controller.openConversation(conversation);
                    Get.to(
                      () => InstructorMessageChatScreen(
                        conversationId: conversation.id,
                      ),
                    );
                  },
                ),
        if (controller.isLoadingMore.value)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(color: Color(0xFF5456E7)),
          ),
      ],
    );
  }

  Widget _buildMessageCard({
    required String name,
    required String message,
    required String time,
    required String imagePath,
    required String initial,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: imagePath.isEmpty
                  ? null
                  : NetworkImage(imagePath),
              child: imagePath.isEmpty
                  ? Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.isEmpty ? "No messages yet." : message,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildTrailing(time: time, unreadCount: unreadCount),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing({required String time, required int unreadCount}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
        ),
        const SizedBox(height: 8),
        if (unreadCount > 0)
          Container(
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF5456E7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (unreadCount == 0) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGroupMessageCard({
    required String name,
    required String message,
    required String time,
    required List<String> avatarUrls,
    required String countText,
    required String initial,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 48,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: _buildStackAvatar(
                      avatarUrls.isNotEmpty ? avatarUrls[0] : '',
                      initial,
                      24,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _buildStackAvatar(
                        avatarUrls.length > 1 ? avatarUrls[1] : '',
                        initial,
                        22,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFD1D5DB),
                        child: Text(
                          countText.isEmpty ? initial : countText,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.isEmpty ? "No messages yet." : message,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildTrailing(time: time, unreadCount: unreadCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStackAvatar(String imagePath, String initial, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: imagePath.isEmpty ? null : NetworkImage(imagePath),
      child: imagePath.isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );
  }
}
