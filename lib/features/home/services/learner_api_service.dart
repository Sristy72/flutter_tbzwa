import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/learner_api_models.dart';

class LearnerApiService {
  final ApiClient _api = ApiClient();

  Future<LearnerProfile> getProfile() async {
    final result = await _api.get<LearnerProfile>(
      endpoint: ApiConstants.user.profile,
      fromJsonT: (json) => LearnerProfile.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<DailyMissionSummary> getDailyMissions() async {
    final result = await _api.get<DailyMissionSummary>(
      endpoint: ApiConstants.progress.dailyMissions,
      fromJsonT: (json) =>
          DailyMissionSummary.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<WeeklyProgress> getWeeklyProgress() async {
    final result = await _api.get<WeeklyProgress>(
      endpoint: ApiConstants.progress.weekly,
      fromJsonT: (json) =>
          WeeklyProgress.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerProgressSnapshot> getProgressSnapshot() async {
    final result = await _api.get<LearnerProgressSnapshot>(
      endpoint: ApiConstants.progress.my,
      fromJsonT: (json) => LearnerProgressSnapshot.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<TodayVocabulary> getTodayVocabulary() async {
    final result = await _api.get<TodayVocabulary>(
      endpoint: ApiConstants.vocabulary.today,
      fromJsonT: (json) =>
          TodayVocabulary.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<VocabularyWord>> getVocabularyWords({
    String? search,
    String? filter,
  }) async {
    final result = await _api.get<List<VocabularyWord>>(
      endpoint: ApiConstants.vocabulary.words,
      queryParameters: {
        'page': 1,
        'limit': 100,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (filter != null && filter.trim().isNotEmpty) 'filter': filter.trim(),
      },
      fromJsonT: (json) => (json['words'] as List? ?? const [])
          .map(
            (item) =>
                VocabularyWord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<VocabularyWord> saveVocabularyWord({
    required String word,
    required String definition,
    required List<String> exampleSentences,
  }) async {
    final result = await _api.post<VocabularyWord>(
      endpoint: ApiConstants.vocabulary.words,
      data: {
        'word': word.trim(),
        'definition': definition.trim(),
        'exampleSentences': exampleSentences
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .take(2)
            .toList(),
      },
      fromJsonT: (json) => VocabularyWord.fromJson(
        Map<String, dynamic>.from(json['vocabulary'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> deleteVocabularyWord(String wordId) async {
    final result = await _api.delete<void>(
      endpoint: ApiConstants.vocabulary.word(wordId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<TodayImmersion> getTodayImmersion() async {
    final result = await _api.get<TodayImmersion>(
      endpoint: ApiConstants.immersion.today,
      fromJsonT: (json) =>
          TodayImmersion.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<TodaySummaryTask> getTodaySummaryTask() async {
    final result = await _api.get<TodaySummaryTask>(
      endpoint: ApiConstants.summary.today,
      fromJsonT: (json) =>
          TodaySummaryTask.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<SummaryHistoryEntry>> getSummaryHistory() async {
    final result = await _api.get<List<SummaryHistoryEntry>>(
      endpoint: ApiConstants.summary.history,
      fromJsonT: (json) => (json['history'] as List? ?? const [])
          .map(
            (item) => SummaryHistoryEntry.fromJson(
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

  Future<List<ImmersionLogEntry>> getImmersionHistory() async {
    final result = await _api.get<List<ImmersionLogEntry>>(
      endpoint: ApiConstants.immersion.history,
      queryParameters: {'page': 1, 'limit': 100},
      fromJsonT: (json) => (json['logs'] as List? ?? const [])
          .map(
            (item) => ImmersionLogEntry.fromJson(
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

  Future<ImmersionLogEntry> saveImmersionLog({
    required String title,
    required String summary,
  }) async {
    final result = await _api.post<ImmersionLogEntry>(
      endpoint: ApiConstants.immersion.logs,
      data: {'title': title.trim(), 'summary': summary.trim()},
      fromJsonT: (json) => ImmersionLogEntry.fromJson(
        Map<String, dynamic>.from(json['log'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> deleteImmersionLog(String logId) async {
    final result = await _api.delete<void>(
      endpoint: ApiConstants.immersion.log(logId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<LearnerProfile> updateProfile({
    required String fullName,
    File? profileImage,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.uri.pathSegments.last,
        ),
    });
    final result = await _api.patch<LearnerProfile>(
      endpoint: ApiConstants.user.profile,
      formData: formData,
      fromJsonT: (json) => LearnerProfile.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<LearnerLiveClasses> getLiveClasses() async {
    final result = await _api.get<LearnerLiveClasses>(
      endpoint: ApiConstants.liveClass.learner,
      fromJsonT: (json) =>
          LearnerLiveClasses.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> setRsvp(String classId, String response) async {
    final result = await _api.post<Map<String, dynamic>>(
      endpoint: ApiConstants.liveClass.rsvp(classId),
      data: {'response': response},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<String> getZoomLink(String classId) async {
    final result = await _api.get<String>(
      endpoint: ApiConstants.liveClass.zoomLink(classId),
      fromJsonT: (json) => (json['zoomLink'] ?? '').toString(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}
