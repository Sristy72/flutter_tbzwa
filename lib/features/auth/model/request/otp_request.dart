class OTPRequest {
  final String email;
  final String otp;

  OTPRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}
