import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/services/smart_media_service.dart';

enum MessageType { text, image, video, audio }

class ChatMessage {
  final String? text;
  final String? mediaPath;
  final MessageType type;
  final String time;
  final bool isMe;
  final String? senderName;
  final String? senderRole;

  ChatMessage({
    this.text,
    this.mediaPath,
    required this.type,
    required this.time,
    required this.isMe,
    this.senderName,
    this.senderRole,
  });
}

class LearnChatController extends GetxController {
  final SmartMediaService _mediaService = Get.find<SmartMediaService>();
  final TextEditingController textController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rxn<ChatMessage> pendingMessage = Rxn<ChatMessage>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    messages.addAll([
      ChatMessage(
        senderName: 'Kathy Onana',
        senderRole: 'Instructor',
        text: "Good morning everyone!\nToday we'll practice restaurant vocabulary. Please listen to the audio and repeat.",
        type: MessageType.text,
        time: '9:00 AM',
        isMe: false,
      ),
      ChatMessage(
        text: "Thank you! I'm ready.",
        type: MessageType.text,
        time: '9:15 AM',
        isMe: true,
      ),
      ChatMessage(
        senderName: 'Wade',
        text: "Today's going to be very...",
        type: MessageType.text,
        time: '9:30 AM',
        isMe: false,
      ),
      ChatMessage(
        type: MessageType.audio,
        time: '9:45 AM',
        isMe: true,
      ),
    ]);
  }

  void sendMessage() {
    final text = textController.text.trim();
    
    // If there's pending media, send it
    if (pendingMessage.value != null) {
      final mediaMsg = pendingMessage.value!;
      final finalMsg = ChatMessage(
        text: text.isNotEmpty ? text : null,
        mediaPath: mediaMsg.mediaPath,
        type: mediaMsg.type,
        time: DateFormat('h:mm a').format(DateTime.now()),
        isMe: true,
      );
      messages.add(finalMsg);
      pendingMessage.value = null;
      textController.clear();
      return;
    }

    // Otherwise send text message if not empty
    if (text.isNotEmpty) {
      final newMessage = ChatMessage(
        text: text,
        type: MessageType.text,
        time: DateFormat('h:mm a').format(DateTime.now()),
        isMe: true,
      );
      messages.add(newMessage);
      textController.clear();
    }
  }

  Future<void> pickImage() async {
    final image = await _mediaService.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pendingMessage.value = ChatMessage(
        mediaPath: image.path,
        type: MessageType.image,
        time: '',
        isMe: true,
      );
    }
  }

  Future<void> pickVideo() async {
    final video = await _mediaService.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      pendingMessage.value = ChatMessage(
        mediaPath: video.path,
        type: MessageType.video,
        time: '',
        isMe: true,
      );
    }
  }

  Future<void> pickAudio() async {
    final files = await _mediaService.pickFiles(type: FileType.audio);
    if (files != null && files.isNotEmpty) {
      pendingMessage.value = ChatMessage(
        mediaPath: files.first.path,
        type: MessageType.audio,
        time: '',
        isMe: true,
      );
    }
  }

  void clearPendingMessage() {
    pendingMessage.value = null;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
