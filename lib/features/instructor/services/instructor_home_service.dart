import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/instructor_home_model.dart';

class InstructorHomeService {
  final ApiClient _api = ApiClient();

  Future<InstructorHomeModel> getHome() async {
    final result = await _api.get<InstructorHomeModel>(
      endpoint: ApiConstants.instructor.home,
      fromJsonT: (json) =>
          InstructorHomeModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<String?> startClass(String classId) async {
    final result = await _api.post<String?>(
      endpoint: ApiConstants.liveClass.start(classId),
      fromJsonT: (json) {
        final map = Map<String, dynamic>.from(json as Map? ?? const {});
        return map['zoomLink']?.toString();
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> createRoom({
    required String name,
    required String groupId,
    required String privacy,
  }) async {
    final result = await _api.post<void>(
      endpoint: ApiConstants.voiceRooms.root,
      data: {
        'name': name.trim(),
        'groupId': groupId,
        'privacy': privacy.toLowerCase(),
      },
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }
}
