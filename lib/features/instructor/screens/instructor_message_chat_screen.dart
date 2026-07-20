import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/instructor_messages_controller.dart';
import '../models/instructor_message_model.dart';

class InstructorMessageChatScreen extends StatefulWidget {
  final String conversationId;

  const InstructorMessageChatScreen({super.key, required this.conversationId});

  @override
  State<InstructorMessageChatScreen> createState() =>
      _InstructorMessageChatScreenState();
}

class _InstructorMessageChatScreenState
    extends State<InstructorMessageChatScreen> {
  late final InstructorMessagesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<InstructorMessagesController>()
        ? Get.find<InstructorMessagesController>()
        : Get.put(InstructorMessagesController());
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
                  "Messages",
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
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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

  void _ensureSelectedConversation() {
    if (_controller.selectedConversation.value?.id == widget.conversationId) {
      if (_controller.messages.isEmpty) {
        _controller.loadMessages(refresh: true);
      }
      return;
    }

    InstructorConversation? match;
    for (final conversation in _controller.conversations) {
      if (conversation.id == widget.conversationId) {
        match = conversation;
        break;
      }
    }
    if (match != null) {
      _controller.openConversation(match);
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
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      }

      if (_controller.messages.isEmpty) {
        return const Center(
          child: Text(
            "No messages yet.",
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
    final showName = conversation?.isGroup == true && !isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 6),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _controller.sendMessage,
            child: Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF5456E7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
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
