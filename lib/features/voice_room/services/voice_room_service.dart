import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/voice_room_model.dart';

class LearnerVoiceRoomService {
  final ApiClient _api = ApiClient();

  Future<LearnerVoiceRoomPage> getRooms({
    required int page,
    required int limit,
    String search = '',
  }) async {
    final query = <String, dynamic>{
      'status': 'active',
      'page': page,
      'limit': limit,
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };

    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.voiceRoom.rooms,
      queryParameters: query,
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => LearnerVoiceRoomPage.fromJson(success.data, success.meta),
    );
  }

  Future<VoiceRoomCreateEligibility> getCreateEligibility() async {
    final result = await _api.get<VoiceRoomCreateEligibility>(
      endpoint: ApiConstants.voiceRoom.createEligibility,
      fromJsonT: (json) => VoiceRoomCreateEligibility.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> createRoom({
    required String name,
    required String privacy,
    required int maxParticipants,
  }) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.rooms,
      data: {
        'name': name.trim(),
        'privacy': privacy.toLowerCase(),
        'maxParticipants': maxParticipants,
      },
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> getRoom(String roomId) async {
    final result = await _api.get<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.room(roomId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> joinRoom(String roomId) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.join(roomId),
      data: const {},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> leaveRoom(String roomId) async {
    final result = await _api.post<void>(
      endpoint: ApiConstants.voiceRoom.leave(roomId),
      data: const {},
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<VoiceRoomMessagePage> getMessages({
    required String roomId,
    required int page,
    required int limit,
    required String currentUserId,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.voiceRoom.messages(roomId),
      queryParameters: {'page': page, 'limit': limit},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => VoiceRoomMessagePage.fromJson(
        success.data,
        success.meta,
        currentUserId,
      ),
    );
  }

  Future<VoiceRoomMessage> sendMessage({
    required String roomId,
    required String content,
    required String clientMessageId,
    required String currentUserId,
    File? attachment,
    String type = 'text',
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'content': content.trim(),
      'type': type,
      'clientMessageId': clientMessageId,
      if (attachment != null)
        'media': await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.uri.pathSegments.last,
        ),
    });

    final result = await _api.post<VoiceRoomMessage>(
      endpoint: ApiConstants.voiceRoom.messages(roomId),
      formData: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return VoiceRoomMessage.fromJson(
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

  Future<VoiceRoomStageInvitation> inviteToStage({
    required String roomId,
    required String targetUserId,
  }) async {
    final result = await _api.post<VoiceRoomStageInvitation>(
      endpoint: ApiConstants.voiceRoom.stageInvite(roomId),
      data: {'targetUserId': targetUserId},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return VoiceRoomStageInvitation.fromJson(
          Map<String, dynamic>.from(data['invitation'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> acceptStageInvite({
    required String roomId,
    required String invitationId,
  }) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.stageInviteAccept(roomId, invitationId),
      data: const {},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> declineStageInvite({
    required String roomId,
    required String invitationId,
  }) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.stageInviteDecline(roomId, invitationId),
      data: const {},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> removeSpeakerFromStage({
    required String roomId,
    required String targetUserId,
  }) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.stageRemove(roomId),
      data: {'targetUserId': targetUserId},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> leaveStage(String roomId) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.stageLeave(roomId),
      data: const {},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerVoiceRoom> setStageMute({
    required String roomId,
    required bool isMuted,
    String? targetUserId,
  }) async {
    final result = await _api.post<LearnerVoiceRoom>(
      endpoint: ApiConstants.voiceRoom.stageMute(roomId),
      data: {
        'isMuted': isMuted,
        if (targetUserId != null && targetUserId.isNotEmpty)
          'targetUserId': targetUserId,
      },
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return LearnerVoiceRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}
