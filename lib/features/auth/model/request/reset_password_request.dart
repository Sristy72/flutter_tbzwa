class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}
