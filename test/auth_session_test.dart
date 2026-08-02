import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/features/auth/model/login_response.dart';

void main() {
  test('login response preserves both tokens required after restart', () {
    final response = LoginResponse.fromJson({
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'user': {
        'id': 'user-1',
        'fullName': 'Test Learner',
        'email': 'learner@example.com',
        'role': 'learner',
      },
    });

    expect(response.accessToken, 'access-token');
    expect(response.refreshToken, 'refresh-token');
    expect(response.user.role, 'learner');
  });
}
