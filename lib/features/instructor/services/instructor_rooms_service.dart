import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/instructor_room_model.dart';

class InstructorRoomsService {
  final ApiClient _api = ApiClient();

  Future<InstructorRoomPage> getRooms({
    required int page,
    required int limit,
    String status = 'active',
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.voiceRooms.root,
      queryParameters: {'page': page, 'limit': limit, 'status': status},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => InstructorRoomPage.fromJson(success.data, success.meta),
    );
  }

  Future<List<InstructorRoomGroup>> getGroups() async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.group.instructorMine,
      queryParameters: const {'page': 1, 'limit': 100, 'status': 'active'},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => (success.data['groups'] as List? ?? const [])
          .map(
            (item) => InstructorRoomGroup.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((group) => group.id.isNotEmpty)
          .toList(),
    );
  }

  Future<InstructorRoom> getRoom(String roomId) async {
    final result = await _api.get<InstructorRoom>(
      endpoint: ApiConstants.voiceRooms.details(roomId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<InstructorRoom> createRoom({
    required String name,
    required String groupId,
    required String privacy,
  }) async {
    final result = await _api.post<InstructorRoom>(
      endpoint: ApiConstants.voiceRooms.root,
      data: {
        'name': name.trim(),
        'groupId': groupId,
        'privacy': privacy.toLowerCase(),
      },
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorRoom.fromJson(
          Map<String, dynamic>.from(data['room'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<InstructorRoom> joinRoom(String roomId) async {
    final result = await _api.post<InstructorRoom>(
      endpoint: ApiConstants.voiceRoom.join(roomId),
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorRoom.fromJson(
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
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }

  Future<void> closeRoom(String roomId) async {
    final result = await _api.delete<void>(
      endpoint: ApiConstants.voiceRooms.close(roomId),
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }
}
