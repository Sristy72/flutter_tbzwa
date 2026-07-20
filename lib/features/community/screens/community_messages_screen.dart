import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../instructor/models/instructor_message_model.dart';
import '../controllers/community_messages_controller.dart';
import 'community_chat_screen.dart';
import 'friend_requests_screen.dart';

class CommunityMessagesScreen extends StatefulWidget {
  const CommunityMessagesScreen({super.key});

  @override
  State<CommunityMessagesScreen> createState() =>
      _CommunityMessagesScreenState();
}

class _CommunityMessagesScreenState extends State<CommunityMessagesScreen> {
  late final CommunityMessagesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CommunityMessagesController>()
        ? Get.find<CommunityMessagesController>()
        : Get.put(CommunityMessagesController());
  }

  @override
  void dispose() {
    controller.clearConversationSelection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectionMode = controller.isSelectionMode;
      return PopScope(
        canPop: !selectionMode,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && controller.isSelectionMode) {
            controller.clearConversationSelection();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F8FC),
          appBar: _buildAppBar(selectionMode: selectionMode),
          body: RefreshIndicator(
            color: const Color(0xFF5456E7),
            onRefresh: controller.refreshConversations,
            child: SingleChildScrollView(
              controller: controller.conversationScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    Obx(() => _buildFriendsOnlineRow()),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 16),
                      child: Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Obx(() => _buildConversationList()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar({required bool selectionMode}) {
    if (selectionMode) {
      final count = controller.selectedConversationCount;
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1E293B), size: 22),
          onPressed: controller.clearConversationSelection,
        ),
        title: Text(
          '$count selected',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: controller.isDeletingConversations.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF3752),
                  ),
            onPressed: controller.isDeletingConversations.value
                ? null
                : _confirmDeleteSelected,
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF1E293B),
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Community',
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => Get.to(() => const FriendRequestsScreen()),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5456E7),
            padding: const EdgeInsets.only(right: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Friend Requests',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          style: const TextStyle(color: Color(0xFF1E293B)),
          controller: controller.searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsOnlineRow() {
    final onlineConversations = controller.conversations
        .where(
          (conversation) =>
              !conversation.isGroup &&
              controller.onlineUserIds.contains(
                conversation.otherParticipant?.id,
              ),
        )
        .toList();
    final onlineCount = onlineConversations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Friends Online',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$onlineCount active',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildNewFriendButton(),
              for (final conversation in onlineConversations.take(12))
                _buildOnlineFriend(conversation),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineFriend(InstructorConversation conversation) {
    final participantId = conversation.otherParticipant?.id ?? '';
    final isActive = controller.onlineUserIds.contains(participantId);
    return GestureDetector(
      onTap: () => _openConversation(conversation),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _buildAvatar(
                    conversation.avatarUrl,
                    controller.initialFor(conversation.title),
                    radius: 30,
                  ),
                ),
                if (isActive)
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFriendButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const FriendRequestsScreen()),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 66,
              width: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
              ),
              child: const Icon(Icons.add, color: Color(0xFF9CA3AF), size: 30),
            ),
            const SizedBox(height: 8),
            const Text(
              'New',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              TextButton(
                onPressed: controller.refreshConversations,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.conversations.isEmpty) {
      final hasSearch = controller.searchController.text.trim().isNotEmpty;
      final message = hasSearch && controller.hasAnyConversation.value
          ? 'No conversations found.'
          : 'No conversations yet.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final conversation in controller.conversations)
          _buildMessageItem(conversation),
        if (controller.isLoadingMore.value)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(color: Color(0xFF5456E7)),
          ),
      ],
    );
  }

  Widget _buildMessageItem(InstructorConversation conversation) {
    final selected = controller.isConversationSelected(conversation.id);
    return GestureDetector(
      onTap: () {
        if (controller.isSelectionMode) {
          controller.toggleConversationSelection(conversation);
        } else {
          _openConversation(conversation);
        }
      },
      onLongPress: () => controller.startConversationSelection(conversation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDEEF7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF5456E7) : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(
              conversation.avatarUrl,
              controller.initialFor(conversation.title),
              radius: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.preview.isEmpty
                        ? 'No messages yet.'
                        : conversation.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            selected ? _buildSelectedIndicator() : _buildTrailing(conversation),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedIndicator() {
    return const Icon(
      Icons.check_circle_rounded,
      color: Color(0xFF5456E7),
      size: 24,
    );
  }

  Widget _buildTrailing(InstructorConversation conversation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          controller.conversationTime(conversation),
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        if (conversation.unreadCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF5456E7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              conversation.unreadCount > 99
                  ? '99+'
                  : conversation.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(
    String? imageUrl,
    String initial, {
    required double radius,
  }) {
    final hasImage = imageUrl?.isNotEmpty == true;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Future<void> _openConversation(InstructorConversation conversation) async {
    await controller.openConversation(conversation);
    if (!mounted) return;
    Get.to(() => CommunityChatScreen(conversationId: conversation.id));
  }

  Future<void> _confirmDeleteSelected() async {
    if (controller.selectedConversationCount == 0) return;

    await Get.dialog<void>(
      Obx(() {
        final count = controller.selectedConversationCount;
        final multiple = count > 1;
        final deleting = controller.isDeletingConversations.value;
        return AlertDialog(
          title: Text(
            multiple ? 'Delete conversations?' : 'Delete conversation?',
          ),
          content: Text(
            multiple
                ? 'Are you sure you want to delete these $count conversations?'
                : 'Are you sure you want to delete this conversation?',
          ),
          actions: [
            TextButton(
              onPressed: deleting ? null : () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: deleting
                  ? null
                  : () async {
                      final success = await controller
                          .deleteSelectedConversations();
                      if (success && Get.isDialogOpen == true) {
                        Get.back();
                      }
                    },
              child: deleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFFF3752)),
                    ),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }
}
