import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/community_post_model.dart';

class CommunityApiService {
  final ApiClient _api = ApiClient();

  Future<CommunityFeedResult> getCommunityFeed({
    String filter = 'recent',
    String search = '',
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.post.posts,
      queryParameters: {
        'filter': filter,
        'page': page,
        'limit': limit,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityFeedResult.fromJson(success.data, success.meta),
    );
  }

  Future<CommunityPost> createPost({
    required String content,
    File? mediaFile,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.post.posts,
      formData: await _postFormData(content: content, mediaFile: mediaFile),
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityPost.fromJson(
        Map<String, dynamic>.from(success.data['post'] as Map),
      ),
    );
  }

  Future<CommunityPost> updatePost({
    required String postId,
    required String content,
    File? mediaFile,
    bool removeMedia = false,
  }) async {
    final result = await _api.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.post.updatePost(postId),
      formData: await _postFormData(
        content: content,
        mediaFile: mediaFile,
        removeMedia: removeMedia,
      ),
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityPost.fromJson(
        Map<String, dynamic>.from(success.data['post'] as Map),
      ),
    );
  }

  Future<void> deletePost(String postId) async {
    final result = await _api.delete<dynamic>(
      endpoint: ApiConstants.post.deletePost(postId),
      fromJsonT: (json) => json,
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<CommunityLikeResult> toggleLike(String postId) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.post.likePost(postId),
      data: const {},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityLikeResult.fromJson(success.data),
    );
  }

  Future<CommunityCommentPage> getComments({
    required String postId,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.post.postComments(postId),
      queryParameters: {'page': page, 'limit': limit},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityCommentPage.fromJson(success.data, success.meta),
    );
  }

  Future<CommunityComment> addComment({
    required String postId,
    required String content,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.post.createComment(postId),
      data: {'content': content.trim()},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => CommunityComment.fromJson(
        Map<String, dynamic>.from(success.data['comment'] as Map),
      ),
    );
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final result = await _api.delete<dynamic>(
      endpoint: ApiConstants.post.deleteComment(postId, commentId),
      fromJsonT: (json) => json,
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<PublicProfileResult> getPublicProfile({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.user.publicProfile(userId),
      queryParameters: {'page': page, 'limit': limit},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => PublicProfileResult.fromJson(success.data, success.meta),
    );
  }

  Future<FriendshipStatus> getFriendshipStatus(String userId) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.friend.friendshipStatus(userId),
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => FriendshipStatus.fromJson(
        success.data['friendshipStatus'] is Map
            ? Map<String, dynamic>.from(success.data['friendshipStatus'] as Map)
            : null,
      ),
    );
  }

  Future<FriendshipStatus> sendFriendRequest(String recipientId) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.friend.sendFriendRequest,
      data: {'recipientId': recipientId},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => FriendshipStatus.fromJson(
        success.data['friendshipStatus'] is Map
            ? Map<String, dynamic>.from(success.data['friendshipStatus'] as Map)
            : null,
      ),
    );
  }

  Future<FriendRequestPage> getFriendRequests({
    required FriendRequestMode mode,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.friend.getFriendRequests,
      queryParameters: {'mode': mode.apiValue, 'page': page, 'limit': limit},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => FriendRequestPage.fromJson(success.data, success.meta, mode),
    );
  }

  Future<FriendshipStatus> respondFriendRequest({
    required String requestId,
    required String action,
  }) async {
    final result = await _api.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.friend.respondFriendRequest(requestId),
      data: {'action': action},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => FriendshipStatus.fromJson(
        success.data['friendshipStatus'] is Map
            ? Map<String, dynamic>.from(success.data['friendshipStatus'] as Map)
            : null,
      ),
    );
  }

  Future<void> removeFriend(String friendshipId) async {
    final result = await _api.delete<dynamic>(
      endpoint: ApiConstants.friend.unfriend(friendshipId),
      fromJsonT: (json) => json,
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  String shareText(CommunityPost post) {
    final text = post.content.trim();
    final link = ApiConstants.post.shareLink(post.id);
    return text.isEmpty ? link : '$text\n$link';
  }

  Future<FormData> _postFormData({
    required String content,
    File? mediaFile,
    bool removeMedia = false,
  }) async {
    return FormData.fromMap({
      'content': content.trim(),
      if (removeMedia) 'removeMedia': 'true',
      if (mediaFile != null)
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: mediaFile.uri.pathSegments.last,
        ),
    });
  }
}

class CommunityLikeResult {
  final bool liked;
  final int likesCount;

  const CommunityLikeResult({required this.liked, required this.likesCount});

  factory CommunityLikeResult.fromJson(Map<String, dynamic> json) {
    final count = json['likesCount'];
    return CommunityLikeResult(
      liked: json['liked'] == true,
      likesCount: count is num ? count.toInt() : int.tryParse('$count') ?? 0,
    );
  }
}
