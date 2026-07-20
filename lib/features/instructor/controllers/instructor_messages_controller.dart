import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/auth_storage_service.dart';
import '../models/instructor_message_model.dart';
import '../services/instructor_messages_service.dart';
import '../services/instructor_messages_socket_service.dart';

class InstructorMessagesController extends GetxController {
  InstructorMessagesController({this.includeGroups = true});

  final bool includeGroups;
  final InstructorMessagesService _service = InstructorMessagesService();
  final InstructorMessagesSocketService _socketService =
      InstructorMessagesSocketService();
  final AuthStorageService _authStorage = Get.find<AuthStorageService>();

  final searchController = TextEditingController();
  final messageTextController = TextEditingController();
  final conversationScrollController = ScrollController();
  final messageScrollController = ScrollController();

  final conversations = <InstructorConversation>[].obs;
  final messages = <InstructorChatMessage>[].obs;
  final selectedConversation = Rxn<InstructorConversation>();

  final isInitialLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final isMessageInitialLoading = false.obs;
  final isLoadingOlderMessages = false.obs;
  final isSendingMessage = false.obs;
  final errorMessage = ''.obs;
  final messageError = ''.obs;
  final onlineUserIds = <String>{}.obs;

  Timer? _searchDebounce;
  String _currentUserId = '';
  int _conversationPage = 1;
  int _conversationTotalPages = 1;
  int _messagePage = 1;
  int _messageTotalPages = 1;

  static const int _conversationLimit = 20;
  static const int _messageLimit = 30;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    conversationScrollController.addListener(_onConversationScroll);
    messageScrollController.addListener(_onMessageScroll);
    _bootstrap();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _socketService.dispose();
    searchController.dispose();
    messageTextController.dispose();
    conversationScrollController.dispose();
    messageScrollController.dispose();
    super.onClose();
  }

  bool get hasMoreConversations => _conversationPage < _conversationTotalPages;
  bool get hasOlderMessages => _messagePage < _messageTotalPages;
  String get currentUserId => _currentUserId;

  Future<void> _bootstrap() async {
    _currentUserId = await _authStorage.getUserId() ?? '';
    _socketService.listen(
      onDirectMessage: _handleDirectSocketMessage,
      onGroupMessage: _handleGroupSocketMessage,
      onMessagesRead: _handleMessagesRead,
      onUserStatus: _handleUserStatus,
    );
    await _socketService.connect(onReconnect: _joinLoadedRooms);
    await loadConversations(refresh: true);
  }

  Future<void> loadConversations({bool refresh = false}) async {
    if (isInitialLoading.value || isRefreshing.value || isLoadingMore.value) {
      return;
    }

    if (refresh) {
      _conversationPage = 1;
      isRefreshing.value = conversations.isNotEmpty;
      isInitialLoading.value = conversations.isEmpty;
    } else if (conversations.isEmpty) {
      isInitialLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';
    try {
      final page = await _service.getConversations(
        page: _conversationPage,
        limit: _conversationLimit,
        search: searchController.text,
        includeGroups: includeGroups,
      );
      _conversationTotalPages = page.totalPages < 1 ? 1 : page.totalPages;
      if (_conversationPage == 1) {
        conversations.assignAll(page.conversations);
      } else {
        for (final conversation in page.conversations) {
          if (!conversations.any((item) => item.id == conversation.id)) {
            conversations.add(conversation);
          }
        }
      }
      _joinLoadedRooms();
    } catch (error) {
      if (!refresh && _conversationPage > 1) {
        _conversationPage -= 1;
      }
      errorMessage.value = _cleanError(error);
    } finally {
      isInitialLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshConversations() async {
    _conversationPage = 1;
    await loadConversations(refresh: true);
  }

  Future<void> loadNextConversationPage() async {
    if (!hasMoreConversations ||
        isInitialLoading.value ||
        isRefreshing.value ||
        isLoadingMore.value) {
      return;
    }
    _conversationPage += 1;
    await loadConversations();
  }

  Future<void> openConversation(InstructorConversation conversation) async {
    final selected = conversation.copyWith(unreadCount: 0);
    selectedConversation.value = selected;
    _replaceConversation(selected, moveToTop: false);
    _joinConversationRoom(selected);
    await loadMessages(refresh: true);
  }

  Future<void> openConversationById(String conversationId) async {
    if (conversationId.trim().isEmpty) return;

    for (final conversation in conversations) {
      if (conversation.id == conversationId.trim()) {
        await openConversation(conversation);
        return;
      }
    }

    final conversation = await _service.getConversation(conversationId.trim());
    if (!includeGroups && conversation.isGroup) {
      throw Exception('Conversation is unavailable.');
    }
    if (!conversations.any((item) => item.id == conversation.id)) {
      conversations.insert(0, conversation);
    }
    await openConversation(conversation);
  }

  Future<InstructorConversation> startDirectConversation(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('User is unavailable.');
    }
    if (_currentUserId.isEmpty) {
      _currentUserId = await _authStorage.getUserId() ?? '';
    }

    InstructorConversation? existing;
    for (final conversation in conversations) {
      if (!conversation.isGroup &&
          conversation.otherParticipant?.id == userId.trim()) {
        existing = conversation;
        break;
      }
    }
    if (existing != null) {
      await openConversation(existing);
      return existing;
    }

    final conversation = await _service.getOrCreateDirectConversation(
      userId.trim(),
    );
    if (!conversations.any((item) => item.id == conversation.id)) {
      conversations.insert(0, conversation);
    }
    await openConversation(conversation);
    return conversation;
  }

  Future<void> loadMessages({bool refresh = false}) async {
    final conversation = selectedConversation.value;
    if (conversation == null || conversation.id.isEmpty) return;
    if (isMessageInitialLoading.value || isLoadingOlderMessages.value) return;

    if (refresh) {
      _messagePage = 1;
      messageError.value = '';
      isMessageInitialLoading.value = true;
    } else {
      if (!hasOlderMessages) return;
      isLoadingOlderMessages.value = true;
    }

    final previousMaxScrollExtent = messageScrollController.hasClients
        ? messageScrollController.position.maxScrollExtent
        : 0.0;

    try {
      final page = await _service.getMessages(
        conversation: conversation,
        page: _messagePage,
        limit: _messageLimit,
        currentUserId: _currentUserId,
      );
      _messageTotalPages = page.totalPages < 1 ? 1 : page.totalPages;
      if (_messagePage == 1) {
        messages.assignAll(_dedupeMessages(page.messages));
        _scrollMessagesToBottom();
        await _markSelectedConversationRead();
      } else {
        final existingIds = messages.map((message) => message.id).toSet();
        final older = page.messages
            .where((message) => !existingIds.contains(message.id))
            .toList();
        messages.insertAll(0, older);
        _restoreOlderMessageScroll(previousMaxScrollExtent);
      }
    } catch (error) {
      if (!refresh && _messagePage > 1) {
        _messagePage -= 1;
      }
      messageError.value = _cleanError(error);
    } finally {
      isMessageInitialLoading.value = false;
      isLoadingOlderMessages.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    if (!hasOlderMessages ||
        isMessageInitialLoading.value ||
        isLoadingOlderMessages.value) {
      return;
    }
    _messagePage += 1;
    await loadMessages();
  }

  Future<void> sendMessage() async {
    final conversation = selectedConversation.value;
    final content = messageTextController.text.trim();
    if (conversation == null || content.isEmpty || isSendingMessage.value) {
      return;
    }

    final tempId = 'temp-${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = InstructorChatMessage.optimistic(
      id: tempId,
      conversationId: conversation.id,
      currentUserId: _currentUserId,
      content: content,
    );

    isSendingMessage.value = true;
    messages.add(optimistic);
    messageTextController.clear();
    _scrollMessagesToBottom();
    _touchConversation(
      conversation.id,
      preview: content,
      latestMessageAt: optimistic.createdAt,
      unreadCount: 0,
      moveToTop: true,
    );

    try {
      final saved = await _service.sendTextMessage(
        conversation: conversation,
        content: content,
        currentUserId: _currentUserId,
      );
      _replaceOptimisticMessage(tempId, saved);
      _touchConversation(
        conversation.id,
        preview: saved.preview,
        latestMessageAt: saved.createdAt,
        unreadCount: 0,
        moveToTop: true,
      );
      _scrollMessagesToBottom();
    } catch (error) {
      final index = messages.indexWhere((message) => message.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          isSending: false,
          isFailed: true,
        );
      }
      _showError(_cleanError(error));
    } finally {
      isSendingMessage.value = false;
    }
  }

  String conversationTime(InstructorConversation conversation) {
    final date = conversation.latestMessageAt;
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(messageDay).inDays;
    if (difference == 0) return DateFormat('h:mm a').format(date);
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d').format(date);
  }

  String messageTime(InstructorChatMessage message) {
    if (message.isSending) return 'Sending...';
    if (message.isFailed) return 'Failed';
    final date = message.createdAt;
    if (date == null) return '';
    return DateFormat('h:mm a').format(date);
  }

  String initialFor(String value) {
    final text = value.trim();
    return text.isEmpty ? 'M' : text[0].toUpperCase();
  }

  String groupCountText(InstructorConversation conversation) {
    final extra = conversation.participantCount - 2;
    if (extra <= 0) return '';
    return extra > 99 ? '99+' : '$extra+';
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      refreshConversations();
    });
  }

  void _onConversationScroll() {
    if (!conversationScrollController.hasClients) return;
    final position = conversationScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      loadNextConversationPage();
    }
  }

  void _onMessageScroll() {
    if (!messageScrollController.hasClients) return;
    if (messageScrollController.position.pixels <= 80) {
      loadOlderMessages();
    }
  }

  void _handleDirectSocketMessage(dynamic data) {
    final payload = _asMap(data);
    final messagePayload = _asMap(payload['message']);
    if (messagePayload.isEmpty) return;
    final conversationId =
        (payload['conversationId'] ?? messagePayload['conversationId'] ?? '')
            .toString();
    if (conversationId.isEmpty) return;

    final message = InstructorChatMessage.fromJson({
      ...messagePayload,
      'conversationId': conversationId,
    }, _currentUserId);
    _handleIncomingMessage(conversationId, message);
  }

  void _handleGroupSocketMessage(dynamic data) {
    final payload = _asMap(data);
    final messagePayload = _asMap(payload['message']);
    final groupId =
        (payload['groupId'] ?? messagePayload['conversationId'] ?? '')
            .toString();
    if (groupId.isEmpty || messagePayload.isEmpty) return;

    final message = InstructorChatMessage.fromJson({
      ...messagePayload,
      'conversationId': groupId,
    }, _currentUserId);
    _handleIncomingMessage(groupId, message);
  }

  void _handleIncomingMessage(
    String conversationId,
    InstructorChatMessage message,
  ) {
    final isCurrent = selectedConversation.value?.id == conversationId;
    if (isCurrent) {
      _appendMessageIfMissing(message);
      _scrollMessagesToBottom();
      if (!selectedConversation.value!.isGroup) {
        _markSelectedConversationRead();
      }
    }

    final existingIndex = conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    final existingUnread = existingIndex == -1
        ? 0
        : conversations[existingIndex].unreadCount;
    _touchConversation(
      conversationId,
      preview: message.preview,
      latestMessageAt: message.createdAt,
      unreadCount: isCurrent || message.isMine ? 0 : existingUnread + 1,
      moveToTop: true,
    );

    if (existingIndex == -1) {
      refreshConversations();
    }
  }

  void _handleMessagesRead(dynamic data) {
    final payload = _asMap(data);
    final conversationId = (payload['conversationId'] ?? '').toString();
    final userId = (payload['userId'] ?? '').toString();
    if (conversationId.isEmpty) return;
    if (userId == _currentUserId) {
      _touchConversation(conversationId, unreadCount: 0, moveToTop: false);
    }
  }

  void _handleUserStatus(dynamic data) {
    final payload = _asMap(data);
    final userId = (payload['userId'] ?? '').toString();
    if (userId.isEmpty) return;
    if (payload['online'] == true) {
      onlineUserIds.add(userId);
    } else {
      onlineUserIds.remove(userId);
    }
  }

  Future<void> _markSelectedConversationRead() async {
    final conversation = selectedConversation.value;
    if (conversation == null || conversation.isGroup) return;
    _touchConversation(conversation.id, unreadCount: 0, moveToTop: false);
    _socketService.markDirectConversationRead(conversation.id);
    try {
      await _service.markConversationRead(conversation.id);
    } catch (_) {
      // getMessages already marks direct messages as read; keep local UI stable.
    }
  }

  void _joinLoadedRooms() {
    for (final conversation in conversations) {
      _joinConversationRoom(conversation);
    }
  }

  void _joinConversationRoom(InstructorConversation conversation) {
    if (conversation.isGroup) {
      _socketService.joinGroup(conversation.id);
    } else {
      _socketService.joinDirectConversation(conversation.id);
    }
  }

  List<InstructorChatMessage> _dedupeMessages(
    List<InstructorChatMessage> items,
  ) {
    final seen = <String>{};
    return items.where((message) {
      if (message.id.isEmpty) return true;
      return seen.add(message.id);
    }).toList();
  }

  void _appendMessageIfMissing(InstructorChatMessage message) {
    if (message.id.isNotEmpty &&
        messages.any((existing) => existing.id == message.id)) {
      return;
    }
    messages.add(message);
  }

  void _replaceOptimisticMessage(String tempId, InstructorChatMessage saved) {
    final existingSavedIndex = messages.indexWhere(
      (message) => message.id == saved.id,
    );
    final tempIndex = messages.indexWhere((message) => message.id == tempId);

    if (existingSavedIndex != -1) {
      if (tempIndex != -1) messages.removeAt(tempIndex);
      return;
    }
    if (tempIndex != -1) {
      messages[tempIndex] = saved;
    } else {
      messages.add(saved);
    }
  }

  void _touchConversation(
    String conversationId, {
    String? preview,
    DateTime? latestMessageAt,
    int? unreadCount,
    bool moveToTop = false,
  }) {
    final index = conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (index == -1) return;

    final updated = conversations[index].copyWith(
      preview: preview,
      latestMessageAt: latestMessageAt,
      unreadCount: unreadCount,
    );
    _replaceConversation(updated, moveToTop: moveToTop);
    if (selectedConversation.value?.id == conversationId) {
      selectedConversation.value = updated;
    }
  }

  void _replaceConversation(
    InstructorConversation conversation, {
    required bool moveToTop,
  }) {
    final index = conversations.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (index == -1) return;
    conversations.removeAt(index);
    conversations.insert(moveToTop ? 0 : index, conversation);
  }

  void _scrollMessagesToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messageScrollController.hasClients) return;
      final position = messageScrollController.position;
      messageScrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _restoreOlderMessageScroll(double previousMaxScrollExtent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messageScrollController.hasClients) return;
      final newMaxScrollExtent =
          messageScrollController.position.maxScrollExtent;
      final delta = newMaxScrollExtent - previousMaxScrollExtent;
      messageScrollController.jumpTo(
        (messageScrollController.offset + delta)
            .clamp(0, newMaxScrollExtent)
            .toDouble(),
      );
    });
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.replaceFirst('Exception: ', '').trim();
  }

  void _showError(String message) {
    if (message.isEmpty || Get.context == null) return;
    Get.snackbar('Messages', message);
  }
}
