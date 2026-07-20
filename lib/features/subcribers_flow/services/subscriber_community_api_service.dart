import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../community/models/community_post_model.dart';
import '../models/subscriber_community_models.dart';

class SubscriberCommunityApiService {
  final ApiClient _api = ApiClient();

  Future<List<SubscriberFriendRequest>> getFriendRequests() async {
    final result = await _api.get<List<SubscriberFriendRequest>>(
      endpoint: ApiConstants.friend.getFriendRequests,
      fromJsonT: (json) => (json['received'] as List? ?? const [])
          .map(
            (item) => SubscriberFriendRequest.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<SubscriberOnlineFriend>> getOnlineFriends() async {
    final result = await _api.get<List<SubscriberOnlineFriend>>(
      endpoint: '${ApiConstants.friend.root}/online',
      fromJsonT: (json) => (json['friends'] as List? ?? const [])
          .map(
            (item) => SubscriberOnlineFriend.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<SubscriberVoiceRoom>> getVoiceRooms() async {
    final result = await _api.get<List<SubscriberVoiceRoom>>(
      endpoint: ApiConstants.voiceRoom.rooms,
      queryParameters: {'status': 'active', 'page': 1, 'limit': 50},
      fromJsonT: (json) => (json['rooms'] as List? ?? const [])
          .map(
            (item) => SubscriberVoiceRoom.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<CommunityPost>> getVideoPosts() async {
    final result = await _api.get<List<CommunityPost>>(
      endpoint: ApiConstants.post.posts,
      queryParameters: {'filter': 'video', 'page': 1, 'limit': 50},
      fromJsonT: (json) => (json['posts'] as List? ?? const [])
          .map(
            (item) =>
                CommunityPost.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> respondToFriendRequest(String requestId, String action) async {
    final result = await _api.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.friend.respondFriendRequest(requestId),
      data: {'action': action},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<void> createVoiceRoom() async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.voiceRoom.rooms,
      data: {'name': 'Conversation Practice', 'privacy': 'public'},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<void> joinVoiceRoom(String roomId) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.voiceRoom.join(roomId),
      data: const {},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }
}
