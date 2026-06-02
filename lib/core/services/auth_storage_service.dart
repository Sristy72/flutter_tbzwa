import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/key_constants.dart';

class AuthStorageService {
  final FlutterSecureStorage _secureStorage;

  AuthStorageService({FlutterSecureStorage? storage})
    : _secureStorage = storage ?? const FlutterSecureStorage();

  // In-memory cache for playlist data
  //PlaylistData? _cachedPlaylistData;

  // Store all auth data (tokens + user ID)
  Future<void> storeAuthData({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? role,
  }) async {
    if (accessToken == null ||
        refreshToken == null ||
        userId == null ||
        role == null) {
      // Handle missing data: throw, log, or use defaults
      throw Exception('Missing required auth data');
    }

    // Store tokens and user ID in parallel for better performance
    await Future.wait([
      _secureStorage.write(key: KeyConst.accessToken, value: accessToken),
      _secureStorage.write(key: KeyConst.refreshToken, value: refreshToken),
      _secureStorage.write(key: KeyConst.userId, value: userId),
      _secureStorage.write(key: KeyConst.role, value: role),
    ]);
  }

  // Store just access token
  Future<void> storeAccessToken({required String accessToken}) async {
    await _secureStorage.write(key: KeyConst.accessToken, value: accessToken);
  }

  // Store just refresh token
  Future<void> storeRefreshToken({required String refreshToken}) async {
    await _secureStorage.write(key: KeyConst.refreshToken, value: refreshToken);
  }

  // Store just user ID
  Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: KeyConst.userId, value: userId);
  }

  // Check user authenticater or not
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final roleString = await _secureStorage.read(key: KeyConst.role);
    return accessToken != null &&
        accessToken.isNotEmpty &&
        roleString != null &&
        roleString.isNotEmpty;
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final accessToken = await _secureStorage.read(key: KeyConst.accessToken);
    return accessToken;
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: KeyConst.refreshToken);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: KeyConst.userId);
  }

  // Get role
  Future<String?> getRole() async {
    return await _secureStorage.read(key: KeyConst.role);
  }

  // Get all auth data at once
  Future<Map<String, String?>> getAllAuthData() async {
    return {
      'accessToken': await getAccessToken(),
      'refreshToken': await getRefreshToken(),
      'userId': await getUserId(),
    };
  }

  // Clear all auth data (logout)
  Future<void> clearAuthData() async {
    //_cachedPlaylistData = null;
    await Future.wait([
      _secureStorage.delete(key: KeyConst.accessToken),
      _secureStorage.delete(key: KeyConst.refreshToken),
      _secureStorage.delete(key: KeyConst.userId),
    ]);
  }

  // Check if user ID exists
  Future<bool> hasUserId() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
