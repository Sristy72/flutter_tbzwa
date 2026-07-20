import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/instructor_profile_model.dart';

class InstructorProfileService {
  final ApiClient _api = ApiClient();

  Future<InstructorProfile> getProfile() async {
    final result = await _api.get<InstructorProfile>(
      endpoint: ApiConstants.user.profile,
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorProfile.fromJson(
          Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<List<InstructorProfileGroup>> getAssignedGroups() async {
    final result = await _api.get<Map<String, dynamic>>(
      endpoint: ApiConstants.group.instructorMine,
      queryParameters: const {'page': 1, 'limit': 100, 'status': 'active'},
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => (success.data['groups'] as List? ?? const [])
          .map(
            (item) => InstructorProfileGroup.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((group) => group.id.isNotEmpty)
          .toList(),
    );
  }

  Future<InstructorProfile> updateProfile({
    required String fullName,
    required String phone,
    required String bio,
    File? profileImage,
    String? changedEmail,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'bio': bio.trim(),
      if (changedEmail != null) 'email': changedEmail.trim(),
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.uri.pathSegments.last,
        ),
    });

    final result = await _api.patch<InstructorProfile>(
      endpoint: ApiConstants.user.profile,
      formData: formData,
      fromJsonT: (json) {
        final data = Map<String, dynamic>.from(json as Map);
        return InstructorProfile.fromJson(
          Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
        );
      },
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success.data,
    );
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    final result = await _api.patch<void>(
      endpoint: ApiConstants.user.profile,
      data: {
        'settings': {'notifications': enabled},
      },
      fromJsonT: (_) {},
    );
    result.fold((failure) => throw Exception(failure.message), (_) {});
  }
}
