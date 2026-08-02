enum InstructorConversationType { direct, group }

class InstructorConversationPage {
  final List<InstructorConversation> conversations;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const InstructorConversationPage({
    required this.conversations,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InstructorConversationPage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    return InstructorConversationPage(
      conversations: (json['conversations'] as List? ?? const [])
          .whereType<Object?>()
          .map((item) {
            try {
              return InstructorConversation.fromJson(
                Map<String, dynamic>.from(item as Map),
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<InstructorConversation>()
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      limit: (meta?['limit'] as num?)?.toInt() ?? 20,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class InstructorConversation {
  final String id;
  final InstructorConversationType type;
  final String title;
  final String preview;
  final DateTime? latestMessageAt;
  final int unreadCount;
  final int participantCount;
  final String? avatarUrl;
  final List<String> avatarUrls;
  final InstructorParticipant? otherParticipant;

  const InstructorConversation({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    required this.latestMessageAt,
    required this.unreadCount,
    required this.participantCount,
    required this.avatarUrl,
    required this.avatarUrls,
    required this.otherParticipant,
  });

  factory InstructorConversation.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? 'direct').toString();
    final type = rawType == 'group'
        ? InstructorConversationType.group
        : InstructorConversationType.direct;
    final other = json['otherParticipant'];
    final avatarValues = (json['avatarUrls'] as List? ?? const [])
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
    final fallbackTitle = type == InstructorConversationType.group
        ? 'Group'
        : 'Deleted user';

    return InstructorConversation(
      id: (json['conversationId'] ?? json['id'] ?? json['_id'] ?? '')
          .toString(),
      type: type,
      title: (json['title'] ?? json['name'] ?? fallbackTitle).toString(),
      preview: (json['latestMessagePreview'] ?? '').toString(),
      latestMessageAt: _parseDate(json['latestMessageAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl']?.toString(),
      avatarUrls: avatarValues,
      otherParticipant: other is Map
          ? InstructorParticipant.fromJson(Map<String, dynamic>.from(other))
          : null,
    );
  }

  bool get isGroup => type == InstructorConversationType.group;

  InstructorConversation copyWith({
    String? preview,
    DateTime? latestMessageAt,
    int? unreadCount,
  }) {
    return InstructorConversation(
      id: id,
      type: type,
      title: title,
      preview: preview ?? this.preview,
      latestMessageAt: latestMessageAt ?? this.latestMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      participantCount: participantCount,
      avatarUrl: avatarUrl,
      avatarUrls: avatarUrls,
      otherParticipant: otherParticipant,
    );
  }
}

class InstructorParticipant {
  final String id;
  final String fullName;
  final String userId;
  final String? avatarUrl;
  final String role;

  const InstructorParticipant({
    required this.id,
    required this.fullName,
    required this.userId,
    required this.avatarUrl,
    required this.role,
  });

  factory InstructorParticipant.fromJson(Map<String, dynamic> json) {
    return InstructorParticipant(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? 'Deleted user').toString(),
      userId: (json['userId'] ?? '').toString(),
      avatarUrl:
          json['profileImageUrl']?.toString() ??
          _imageUrl(json['profileImage']),
      role: (json['role'] ?? '').toString(),
    );
  }
}

class InstructorMessagePage {
  final List<InstructorChatMessage> messages;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const InstructorMessagePage({
    required this.messages,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InstructorMessagePage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
    String currentUserId,
  ) {
    return InstructorMessagePage(
      messages: (json['messages'] as List? ?? const [])
          .whereType<Object?>()
          .map((item) {
            try {
              return InstructorChatMessage.fromJson(
                Map<String, dynamic>.from(item as Map),
                currentUserId,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<InstructorChatMessage>()
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      limit: (meta?['limit'] as num?)?.toInt() ?? 30,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class InstructorChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final String type;
  final String? mediaUrl;
  final DateTime? createdAt;
  final bool isMine;
  final bool isInstructor;
  final bool isSending;
  final bool isFailed;

  const InstructorChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.mediaUrl,
    required this.createdAt,
    required this.isMine,
    required this.isInstructor,
    this.isSending = false,
    this.isFailed = false,
  });

  factory InstructorChatMessage.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final sender = json['senderId'];
    final senderJson = sender is Map ? Map<String, dynamic>.from(sender) : null;
    final senderId = (senderJson?['id'] ?? senderJson?['_id'] ?? sender ?? '')
        .toString();
    final media = json['mediaFile'];
    final mediaJson = media is Map ? Map<String, dynamic>.from(media) : null;

    return InstructorChatMessage(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      senderId: senderId,
      senderName: (senderJson?['fullName'] ?? 'Member').toString(),
      senderAvatarUrl: _imageUrl(senderJson?['profileImage']),
      content: (json['content'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      mediaUrl: mediaJson?['url']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      isMine: senderId == currentUserId,
      isInstructor:
          json['isInstructor'] == true ||
          (senderJson?['role'] ?? '').toString() == 'instructor',
    );
  }

  factory InstructorChatMessage.optimistic({
    required String id,
    required String conversationId,
    required String currentUserId,
    required String content,
  }) {
    return InstructorChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: currentUserId,
      senderName: 'You',
      senderAvatarUrl: null,
      content: content,
      type: 'text',
      mediaUrl: null,
      createdAt: DateTime.now(),
      isMine: true,
      isInstructor: true,
      isSending: true,
    );
  }

  String get preview {
    final text = content.trim();
    if (text.isNotEmpty) return text;
    if (type == 'image') return 'Image';
    if (type == 'audio') return 'Audio message';
    if (type == 'video') return 'Video message';
    return 'Message';
  }

  InstructorChatMessage copyWith({bool? isSending, bool? isFailed}) {
    return InstructorChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: createdAt,
      isMine: isMine,
      isInstructor: isInstructor,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String? _imageUrl(dynamic image) {
  if (image == null) return null;
  if (image is String) return image.isEmpty ? null : image;
  if (image is Map) {
    final map = Map<String, dynamic>.from(image);
    return map['url']?.toString() ?? map['secure_url']?.toString();
  }
  return null;
}
