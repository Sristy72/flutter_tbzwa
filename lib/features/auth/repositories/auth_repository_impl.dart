import '../../../core/api/api_client.dart';
import '../../../core/api/network_result.dart';
import '../../../core/constants/api_constants.dart';
import '../model/login_response.dart';
import '../model/request/login_request.dart';
import '../model/request/otp_request.dart';
import '../model/request/register_request.dart';
import '../model/request/reset_password_request.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  NetworkResult<LoginResponse> login(LoginRequest request) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.login,
      data: request.toJson(),
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );
  }

  @override
  NetworkResult<void> register(RegisterRequest request) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.register,
      data: request.toJson(),
      fromJsonT: (json) {},
    );
  }

  @override
  NetworkResult<LoginResponse> verifyEmail(OTPRequest request) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.verifyEmail,
      data: request.toJson(),
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );
  }

  @override
  NetworkResult<LoginResponse> selectRole(String role) {
    return _apiClient.patch(
      endpoint: ApiConstants.auth.selectRole,
      data: {'role': role},
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );
  }

  @override
  NetworkResult<void> resendOTP(String email) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.resendOTP,
      data: {'email': email},
      fromJsonT: (json) {},
    );
  }

  @override
  NetworkResult<void> forgotPassword(String email) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.forgotPassword,
      data: {'email': email},
      fromJsonT: (json) {},
    );
  }

  @override
  NetworkResult<String> verifyResetOTP(OTPRequest request) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.verifyResetOTP,
      data: request.toJson(),
      fromJsonT: (json) => json['resetToken'] as String,
    );
  }

  @override
  NetworkResult<void> resetPassword(ResetPasswordRequest request) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.resetPassword,
      data: request.toJson(),
      fromJsonT: (json) {},
    );
  }

  @override
  NetworkResult<String> refreshToken(String refreshToken) {
    return _apiClient.post(
      endpoint: ApiConstants.auth.refreshToken,
      data: {'refreshToken': refreshToken},
      fromJsonT: (json) => json['accessToken'] as String,
    );
  }

  @override
  NetworkResult<void> logout() {
    return _apiClient.post(
      endpoint: ApiConstants.auth.logout,
      fromJsonT: (json) {},
    );
  }
}
