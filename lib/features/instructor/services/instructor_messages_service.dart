import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/instructor_message_model.dart';

class InstructorMessagesService {
  final ApiClient _api = ApiClient();

  Future<InstructorConversationPage> getConversations({
    required int page,
    required int limit,
    required String search,
    bool includeGroups = true,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      'includeGroups': includeGroups,
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };

    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.chat.getMyConversations,
      queryParameters: query,
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) =>
          InstructorConversationPage.fromJson(success.data, success.meta),
    );
  }

  Future<InstructorConversation> getOrCreateDirectConversation(
    String userId,
  ) async {
    final result = await _api.post<InstructorConversation>(
      endpoint: ApiConstants.chat.createDirectConversation,
      data: {'userId': userId},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        final conversation = Map<String, dynamic>.from(
          data['conversation'] as Map? ?? const {},
        );
        final otherParticipant = Map<String, dynamic>.from(
          data['otherParticipant'] as Map? ?? const {},
        );

        return InstructorConversation.fromJson({
          ...conversation,
          'type': 'direct',
          'title': otherParticipant['fullName'] ?? conversation['title'],
          'avatarUrl':
              otherParticipant['profileImageUrl'] ??
              _imageUrl(otherParticipant['profileImage']),
          'otherParticipant': otherParticipant,
        });
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<InstructorConversation> getConversation(String conversationId) async {
    final result = await _api.get<InstructorConversation>(
      endpoint: ApiConstants.chat.getConversationByID(conversationId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorConversation.fromJson(
          Map<String, dynamic>.from(data['conversation'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<InstructorMessagePage> getMessages({
    required InstructorConversation conversation,
    required int page,
    required int limit,
    required String currentUserId,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: conversation.isGroup
          ? ApiConstants.group.discussion(conversation.id)
          : ApiConstants.chat.getChatMessages(conversation.id),
      queryParameters: {'page': page, 'limit': limit},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => InstructorMessagePage.fromJson(
        success.data,
        success.meta,
        currentUserId,
      ),
    );
  }

  Future<InstructorChatMessage> sendTextMessage({
    required InstructorConversation conversation,
    required String content,
    required String currentUserId,
  }) async {
    final result = await _api.post<InstructorChatMessage>(
      endpoint: conversation.isGroup
          ? ApiConstants.group.discussion(conversation.id)
          : ApiConstants.chat.sendDirectMessage(conversation.id),
      data: conversation.isGroup
          ? {'content': content.trim()}
          : {'conversationId': conversation.id, 'content': content.trim()},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorChatMessage.fromJson(
          Map<String, dynamic>.from(data['message'] as Map? ?? const {}),
          currentUserId,
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> markConversationRead(String conversationId) async {
    final result = await _api.patch<void>(
      endpoint: ApiConstants.chat.markConversationRead(conversationId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<ConversationDeleteResult> deleteConversationsForMe(
    List<String> conversationIds,
  ) async {
    final result = await _api.delete<ConversationDeleteResult>(
      endpoint: ApiConstants.chat.deleteConversations,
      data: {'conversationIds': conversationIds},
      fromJsonT: (json) => ConversationDeleteResult.fromJson(
        Map<String, dynamic>.from(json as Map? ?? const {}),
      ),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}

class ConversationDeleteResult {
  final int requestedCount;
  final int hiddenCount;
  final int notFoundOrUnauthorizedCount;
  final List<String> hiddenConversationIds;

  const ConversationDeleteResult({
    required this.requestedCount,
    required this.hiddenCount,
    required this.notFoundOrUnauthorizedCount,
    required this.hiddenConversationIds,
  });

  factory ConversationDeleteResult.fromJson(Map<String, dynamic> json) {
    return ConversationDeleteResult(
      requestedCount: _asInt(json['requestedCount']),
      hiddenCount: _asInt(json['hiddenCount']),
      notFoundOrUnauthorizedCount: _asInt(json['notFoundOrUnauthorizedCount']),
      hiddenConversationIds:
          (json['hiddenConversationIds'] as List? ?? const [])
              .map((id) => id.toString())
              .where((id) => id.isNotEmpty)
              .toList(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
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
