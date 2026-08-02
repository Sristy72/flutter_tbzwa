import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/note_model.dart';

class BZPadNotesResult {
  final List<NoteModel> myNotes;
  final List<NoteModel> recentNotes;

  const BZPadNotesResult({required this.myNotes, required this.recentNotes});

  factory BZPadNotesResult.fromJson(Map<String, dynamic> json) {
    List<NoteModel> parse(String key) => (json[key] as List? ?? const [])
        .map(
          (item) => NoteModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    return BZPadNotesResult(
      myNotes: parse('myNotes'),
      recentNotes: parse('recentNotes'),
    );
  }
}

class BZPadApiService {
  final ApiClient _api = ApiClient();

  Future<BZPadNotesResult> getNotes() async {
    final result = await _api.get<BZPadNotesResult>(
      endpoint: ApiConstants.bzPad.notes,
      fromJsonT: (json) =>
          BZPadNotesResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<NoteModel> getNote(String id) async {
    final result = await _api.get<NoteModel>(
      endpoint: ApiConstants.bzPad.note(id),
      fromJsonT: (json) =>
          NoteModel.fromJson(Map<String, dynamic>.from(json['note'] as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<NoteModel> createNote(String title, String content) async {
    final result = await _api.post<NoteModel>(
      endpoint: ApiConstants.bzPad.notes,
      data: {'title': title, 'content': content},
      fromJsonT: (json) =>
          NoteModel.fromJson(Map<String, dynamic>.from(json['note'] as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<NoteModel> updateNote(String id, String title, String content) async {
    final result = await _api.patch<NoteModel>(
      endpoint: ApiConstants.bzPad.note(id),
      data: {'title': title, 'content': content, 'saveType': 'manual'},
      fromJsonT: (json) =>
          NoteModel.fromJson(Map<String, dynamic>.from(json['note'] as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> deleteNote(String id) async {
    final result = await _api.delete<void>(
      endpoint: ApiConstants.bzPad.note(id),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final result = await _api.get<List<NoteModel>>(
      endpoint: ApiConstants.bzPad.search,
      queryParameters: {'q': query},
      fromJsonT: (json) => (json['notes'] as List? ?? const [])
          .map(
            (item) =>
                NoteModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<NoteVersionModel>> getVersions(String id) async {
    final result = await _api.get<List<NoteVersionModel>>(
      endpoint: ApiConstants.bzPad.versions(id),
      fromJsonT: (json) => (json['versions'] as List? ?? const [])
          .map(
            (item) => NoteVersionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
              id,
            ),
          )
          .toList(),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<NoteModel> restoreVersion(String id, int versionIndex) async {
    final result = await _api.post<NoteModel>(
      endpoint: ApiConstants.bzPad.restore(id),
      data: {'versionIndex': versionIndex},
      fromJsonT: (json) =>
          NoteModel.fromJson(Map<String, dynamic>.from(json['note'] as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}
