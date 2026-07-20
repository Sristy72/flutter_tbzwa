class LoginResponse {
  final UserInfo user;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserInfo.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }
}

class UserInfo {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? profileImageUrl;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'learner',
      profileImageUrl: json['profileImage']?['url'],
    );
  }
}
