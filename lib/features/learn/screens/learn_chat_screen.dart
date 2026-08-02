import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/core/constants/assest_const.dart';
import 'package:flutter_tbzwa/features/learn/controllers/learn_chat_controller.dart';
import 'package:get/get.dart';

import 'class_details_screen.dart';
import 'live_classes_screen.dart';

class LearnChatScreen extends StatelessWidget {
  final String batchName;
  final String lastMessage;
  final String imageUrl;

  LearnChatScreen({
    super.key,
    required this.batchName,
    required this.lastMessage,
    required this.imageUrl,
  });

  final controller = Get.put(LearnChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batchName,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lastMessage,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2FBDA3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.push_pin_outlined, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pinned Message',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'https://zoom.us/j/123456789?pwd=123456',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          GestureDetector(onTap: () => Get.to(() => const LiveClassesScreen()),
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(decoration:BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Color(0xFFB0FDEC),
              border: Border.all(
                color: Color(0xFF22A892)
              )
            ),child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
              child: Text('Join class', style: TextStyle(color: Colors.black),),
            )),
          ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  if (message.isMe) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildMyMessageFromModel(message),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildOtherMessageFromModel(message),
                    );
                  }
                },
              ),
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMyMessageFromModel(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return _buildMyMessage(message: message.text!, time: message.time);
      case MessageType.image:
        return _buildMyMediaMessage(path: message.mediaPath!, time: message.time, icon: Icons.image);
      case MessageType.video:
        return _buildMyMediaPreview(path: message.mediaPath!, time: message.time);
      case MessageType.audio:
        return _buildMyAudioMessage(time: message.time);
    }
  }

  Widget _buildOtherMessageFromModel(ChatMessage message) {
    return _buildMessageBubble(
      name: message.senderName ?? 'User',
      role: message.senderRole,
      message: message.text ?? '',
      time: message.time,
      isInstructor: message.senderRole?.toLowerCase() == 'instructor',
    );
  }

  Widget _buildMessageBubble({
    required String name,
    String? role,
    required String message,
    required String time,
    bool isInstructor = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage(AssetsConstants.images.profileImage),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (isInstructor) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: Color(0xFF2FBDA3), size: 16),
                    ],
                  ],
                ),
                if (role != null)
                  Text(
                    role,
                    style: const TextStyle(
                      color: Color(0xFF2FBDA3),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF64748B).withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyMessage({required String message, required String time}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF64748B).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyMediaMessage({required String path, required String time, required IconData icon}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(path),
                width: 200,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF64748B).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyMediaPreview({required String path, required String time}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F6F4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2FBDA3).withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF2FBDA3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 16,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF64748B).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAudioMessage({required String time}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.graphic_eq_rounded, color: Color(0xFF2FBDA3), size: 24),
            const SizedBox(width: 8),
            Text(
              '||||||||||||||||||||||||||||||||||||||||||',
              style: TextStyle(
                color: const Color(0xFF2FBDA3).withOpacity(0.6),
                letterSpacing: -1,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF64748B).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          if (controller.pendingMessage.value != null) {
            return _buildPendingMediaPreview();
          }
          return const SizedBox.shrink();
        }),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8FC),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(color: const Color(0xFFE3E7EE)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => controller.sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAttachmentMenu(context),
                        child: const Icon(Icons.add_rounded, color: Color(0xFF94A3B8), size: 28),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.sendMessage(),
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD0F8F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF22A892), size: 26),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingMediaPreview() {
    final pending = controller.pendingMessage.value!;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (pending.type == MessageType.image)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(pending.mediaPath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else if (pending.type == MessageType.video)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.videocam_rounded, color: Color(0xFF2FBDA3)),
            )
          else if (pending.type == MessageType.audio)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic_none_rounded, color: Color(0xFF2FBDA3)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selected ${pending.type.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
            onPressed: () => controller.clearPendingMessage(),
          ),
        ],
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttachmentOption(
                icon: Icons.image_outlined,
                label: 'Image',
                onTap: () {
                  Get.back();
                  controller.pickImage();
                },
              ),
              const SizedBox(height: 20),
              _buildAttachmentOption(
                icon: Icons.mic_none_rounded,
                label: 'Audio',
                onTap: () {
                  Get.back();
                  controller.pickAudio();
                },
              ),
              const SizedBox(height: 20),
              _buildAttachmentOption(
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: () {
                  Get.back();
                  controller.pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEBFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2FBDA3), size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
