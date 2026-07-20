class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String? referralCode;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.referralCode,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    if (referralCode != null) 'referralCode': referralCode,
  };
}
