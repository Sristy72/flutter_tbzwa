import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../instructor/models/instructor_message_model.dart';
import '../controllers/community_messages_controller.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

class CommunityChatScreen extends StatefulWidget {
  final String conversationId;

  const CommunityChatScreen({super.key, required this.conversationId});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  late final CommunityMessagesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CommunityMessagesController>()
        ? Get.find<CommunityMessagesController>()
        : Get.put(CommunityMessagesController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSelectedConversation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final conversation = _controller.selectedConversation.value;
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B),
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: conversation == null
              ? const Text(
                  'Messages',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Row(
                  children: [
                    _buildHeaderAvatar(conversation),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          actions: [
            IconButton(
              icon: _headerActionIcon(Icons.phone_outlined),
              onPressed: conversation == null
                  ? null
                  : () => Get.to(
                      () => AudioCallScreen(
                        name: conversation.title,
                        imageUrl: _callImageUrl(conversation),
                      ),
                    ),
            ),
            IconButton(
              icon: _headerActionIcon(Icons.videocam_outlined),
              onPressed: conversation == null
                  ? null
                  : () => Get.to(
                      () => VideoCallScreen(
                        name: conversation.title,
                        imageUrl: _callImageUrl(conversation),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessages(conversation)),
            _buildInputArea(),
          ],
        ),
      );
    });
  }

  Future<void> _ensureSelectedConversation() async {
    if (_controller.selectedConversation.value?.id == widget.conversationId) {
      if (_controller.messages.isEmpty) {
        await _controller.loadMessages(refresh: true);
      }
      return;
    }

    try {
      await _controller.openConversationById(widget.conversationId);
    } catch (_) {
      await _controller.loadConversations(refresh: true);
      if (_controller.selectedConversation.value?.id != widget.conversationId) {
        await _controller.openConversationById(widget.conversationId);
      }
    }
  }

  Widget _buildMessages(InstructorConversation? conversation) {
    return Obx(() {
      if (_controller.isMessageInitialLoading.value &&
          _controller.messages.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF5456E7)),
        );
      }

      if (_controller.messageError.value.isNotEmpty &&
          _controller.messages.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.messageError.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                TextButton(
                  onPressed: () => _controller.loadMessages(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (_controller.messages.isEmpty) {
        return const Center(
          child: Text(
            'No messages yet.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        );
      }

      return ListView.builder(
        controller: _controller.messageScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _controller.messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _controller.isLoadingOlderMessages.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF5456E7),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final message = _controller.messages[index - 1];
          return _buildMessageBubble(
            conversation: conversation,
            message: message,
          );
        },
      );
    });
  }

  Widget _buildMessageBubble({
    required InstructorConversation? conversation,
    required InstructorChatMessage message,
  }) {
    final isMe = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                _buildMessageAvatar(message, conversation),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF5456E7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Text(
                    message.content.isEmpty ? message.preview : message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 48, right: isMe ? 4 : 0),
            child: Text(
              _controller.messageTime(message),
              style: TextStyle(
                fontSize: 10,
                color: message.isFailed
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller.messageTextController,
                style: const TextStyle(color: Color(0xFF1B1A1A)),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => GestureDetector(
              onTap: _controller.isSendingMessage.value
                  ? null
                  : _controller.sendMessage,
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: _controller.isSendingMessage.value
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF5456E7),
                  shape: BoxShape.circle,
                ),
                child: _controller.isSendingMessage.value
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF5456E7), size: 18),
    );
  }

  String _callImageUrl(InstructorConversation conversation) {
    final imageUrl = conversation.avatarUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) return imageUrl;
    return '';
  }

  Widget _buildHeaderAvatar(InstructorConversation conversation) {
    final imageUrl = conversation.avatarUrl;
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: imageUrl == null || imageUrl.isEmpty
          ? null
          : NetworkImage(imageUrl),
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              _controller.initialFor(conversation.title),
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageAvatar(
    InstructorChatMessage message,
    InstructorConversation? conversation,
  ) {
    final imageUrl = message.senderAvatarUrl ?? conversation?.avatarUrl;
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: imageUrl == null || imageUrl.isEmpty
          ? null
          : NetworkImage(imageUrl),
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              _controller.initialFor(message.senderName),
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
