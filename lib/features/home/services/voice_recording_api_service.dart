import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/voice_recording_model.dart';

class VoiceRecordingApiService {
  final ApiClient _api = ApiClient();

  Future<List<VoiceRecordingModel>> getRecordingsForDate(DateTime date) async {
    return _getRecordingsForDate(date, type: 'voice');
  }

  Future<List<VoiceRecordingModel>> getVideoRecordingsForDate(
    DateTime date,
  ) async {
    return _getRecordingsForDate(date, type: 'video');
  }

  Future<List<VoiceRecordingModel>> getSummaryRecordingsForDate(
    DateTime date,
  ) async {
    return _getRecordingsForDate(date, type: 'summary');
  }

  Future<List<VoiceRecordingModel>> _getRecordingsForDate(
    DateTime date, {
    required String type,
  }) async {
    final result = await _api.get<List<VoiceRecordingModel>>(
      endpoint: ApiConstants.recording.my,
      queryParameters: {
        'type': type,
        'missionDate': _dateOnly(date),
        'page': 1,
        'limit': 100,
      },
      fromJsonT: (json) => (json['recordings'] as List? ?? const [])
          .map(
            (item) => VoiceRecordingModel.fromJson(
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

  Future<VoiceRecordingModel> uploadVoiceRecording({
    required File audioFile,
    required int duration,
    required DateTime recordedAt,
    String? label,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.uri.pathSegments.last,
      ),
      if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
      'duration': duration,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'timezoneOffsetMinutes': recordedAt.timeZoneOffset.inMinutes,
      'missionDate': _dateOnly(recordedAt),
    });

    final result = await _api.post<VoiceRecordingModel>(
      endpoint: ApiConstants.recording.voice,
      formData: formData,
      fromJsonT: (json) => VoiceRecordingModel.fromJson(
        Map<String, dynamic>.from(json['recording'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> deleteRecording(String recordingId) async {
    final result = await _api.delete<void>(
      endpoint: ApiConstants.recording.recording(recordingId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<VoiceRecordingModel> uploadVideoRecording({
    required File videoFile,
    required int duration,
    required DateTime recordedAt,
    String? label,
  }) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.uri.pathSegments.last,
      ),
      if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
      'duration': duration,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'timezoneOffsetMinutes': recordedAt.timeZoneOffset.inMinutes,
      'missionDate': _dateOnly(recordedAt),
    });

    final result = await _api.post<VoiceRecordingModel>(
      endpoint: ApiConstants.recording.video,
      formData: formData,
      fromJsonT: (json) => VoiceRecordingModel.fromJson(
        Map<String, dynamic>.from(json['recording'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<VoiceRecordingModel> uploadSummaryRecording({
    required File audioFile,
    required int duration,
    required DateTime recordedAt,
    String? label,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.uri.pathSegments.last,
      ),
      if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
      'duration': duration,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'timezoneOffsetMinutes': recordedAt.timeZoneOffset.inMinutes,
      'missionDate': _dateOnly(recordedAt),
    });

    final result = await _api.post<VoiceRecordingModel>(
      endpoint: ApiConstants.recording.summary,
      formData: formData,
      fromJsonT: (json) => VoiceRecordingModel.fromJson(
        Map<String, dynamic>.from(json['recording'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  String _dateOnly(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
