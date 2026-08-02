class InstructorProfile {
  final String id;
  final String fullName;
  final String userId;
  final String email;
  final String phone;
  final String bio;
  final String role;
  final String? profileImageUrl;
  final bool notificationsEnabled;

  const InstructorProfile({
    required this.id,
    required this.fullName,
    required this.userId,
    required this.email,
    required this.phone,
    required this.bio,
    required this.role,
    required this.profileImageUrl,
    required this.notificationsEnabled,
  });

  factory InstructorProfile.fromJson(Map<String, dynamic> json) {
    final image = json['profileImage'];
    final imageJson = image is Map ? Map<String, dynamic>.from(image) : null;
    final settings = json['settings'];
    final settingsJson = settings is Map
        ? Map<String, dynamic>.from(settings)
        : const <String, dynamic>{};
    return InstructorProfile(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      role: (json['role'] ?? 'instructor').toString(),
      profileImageUrl: imageJson?['url']?.toString(),
      notificationsEnabled: settingsJson['notifications'] != false,
    );
  }

  String get displayName => fullName.trim().isEmpty ? 'Instructor' : fullName;

  String get displayEmail => email.trim().isEmpty ? 'Email unavailable' : email;

  String get displayPhone => phone.trim().isEmpty ? 'Phone unavailable' : phone;

  String get displayBio => bio.trim().isEmpty ? 'No bio added yet.' : bio;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'I';
    if (parts.length == 1) return _firstLetter(parts.first);
    return '${_firstLetter(parts.first)}${_firstLetter(parts.last)}';
  }

  String _firstLetter(String value) {
    if (value.isEmpty) return 'I';
    return String.fromCharCode(value.runes.first).toUpperCase();
  }

  InstructorProfile copyWith({
    String? fullName,
    String? phone,
    String? bio,
    String? profileImageUrl,
    bool? notificationsEnabled,
  }) {
    return InstructorProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      userId: userId,
      email: email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      role: role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class InstructorProfileGroup {
  final String id;
  final String name;
  final String? themeColor;
  final int totalStudents;
  final int activeStudentCount;

  const InstructorProfileGroup({
    required this.id,
    required this.name,
    required this.themeColor,
    required this.totalStudents,
    required this.activeStudentCount,
  });

  factory InstructorProfileGroup.fromJson(Map<String, dynamic> json) {
    return InstructorProfileGroup(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      themeColor: json['themeColor']?.toString(),
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      activeStudentCount:
          (json['activeStudentCount'] as num?)?.toInt() ??
          (json['totalStudents'] as num?)?.toInt() ??
          0,
    );
  }

  int get displayStudentCount =>
      activeStudentCount > 0 ? activeStudentCount : totalStudents;

  String get displayName => name.trim().isEmpty ? 'Untitled Group' : name;

  String get letter =>
      String.fromCharCode(displayName.runes.first).toUpperCase();
}
