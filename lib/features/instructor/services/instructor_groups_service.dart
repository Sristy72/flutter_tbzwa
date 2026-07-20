import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/instructor_group_model.dart';

class InstructorGroupsService {
  final ApiClient _api = ApiClient();

  Future<InstructorGroupPage> getGroups({
    required int page,
    required int limit,
    required String search,
    required String status,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (status != 'all') 'status': status,
    };

    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.group.instructorMine,
      queryParameters: query,
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => InstructorGroupPage.fromJson(success.data, success.meta),
    );
  }

  Future<InstructorGroup> getGroup(String groupId) async {
    final result = await _api.get<InstructorGroup>(
      endpoint: ApiConstants.group.groupByID(groupId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorGroup.fromJson(
          Map<String, dynamic>.from(data['group'] as Map? ?? const {}),
        );
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<InstructorGroupMember>> getMembers(String groupId) async {
    final result = await _api.get<List<InstructorGroupMember>>(
      endpoint: ApiConstants.group.getGroupMembers(groupId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return (data['members'] as List? ?? const [])
            .map(
              (item) => InstructorGroupMember.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<InstructorGroupMessage>> getDiscussion(String groupId) async {
    final result = await _api.get<List<InstructorGroupMessage>>(
      endpoint: ApiConstants.group.discussion(groupId),
      queryParameters: const {'page': 1, 'limit': 30},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return (data['messages'] as List? ?? const [])
            .map(
              (item) => InstructorGroupMessage.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<InstructorGroupMessage> sendMessage({
    required String groupId,
    required String content,
  }) async {
    final result = await _api.post<InstructorGroupMessage>(
      endpoint: ApiConstants.group.discussion(groupId),
      data: {'content': content.trim()},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorGroupMessage.fromJson(
          Map<String, dynamic>.from(data['message'] as Map? ?? const {}),
        );
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<InstructorGroupRoom>> getRooms(String groupId) async {
    final result = await _api.get<List<InstructorGroupRoom>>(
      endpoint: ApiConstants.voiceRooms.root,
      queryParameters: {'groupId': groupId},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return (data['rooms'] as List? ?? const [])
            .map(
              (item) => InstructorGroupRoom.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> createRoom({
    required String groupId,
    required String name,
    required String privacy,
  }) async {
    final result = await _api.post<void>(
      endpoint: ApiConstants.voiceRooms.root,
      data: {
        'groupId': groupId,
        'name': name.trim(),
        'privacy': privacy.toLowerCase(),
      },
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<void> joinRoom(String roomId) async {
    final result = await _api.post<void>(
      endpoint: ApiConstants.voiceRoom.join(roomId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<List<InstructorGroupClass>> getUpcomingClasses(String groupId) async {
    final result = await _api.get<List<InstructorGroupClass>>(
      endpoint: ApiConstants.liveClass.byGroup(groupId),
      queryParameters: const {'filter': 'upcoming', 'page': 1, 'limit': 5},
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return (data['classes'] as List? ?? const [])
            .map(
              (item) => InstructorGroupClass.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
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
        final data = Map<String, dynamic>.from(json as Map? ?? const {});
        return data['zoomLink']?.toString();
      },
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }
}
