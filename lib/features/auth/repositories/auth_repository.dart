import '../model/request/login_request.dart';
import '../model/request/register_request.dart';
import '../model/request/otp_request.dart';
import '../model/request/reset_password_request.dart';
import '../model/login_response.dart';
import '../../../core/api/network_result.dart';

abstract class AuthRepository {
  NetworkResult<LoginResponse> login(LoginRequest request);
  NetworkResult<void> register(RegisterRequest request);
  NetworkResult<LoginResponse> verifyEmail(OTPRequest request);
  NetworkResult<LoginResponse> selectRole(String role);
  NetworkResult<void> resendOTP(String email);
  NetworkResult<void> forgotPassword(String email);
  NetworkResult<String> verifyResetOTP(OTPRequest request);
  NetworkResult<void> resetPassword(ResetPasswordRequest request);
  NetworkResult<String> refreshToken(String refreshToken);
  NetworkResult<void> logout();
}
