import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

import 'api_client.dart';
import '../../features/auth/domain/entities/user.dart';

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final _dio = ApiClient().dio;

  /// Returns `true` if a valid token is stored in secure storage.
  Future<bool> isLoggedIn() => ApiClient.hasToken();

  /// Attempts login. On success saves the token and returns the [User].
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        kLoginEndpoint,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      await ApiClient.saveToken(data['token'] as String);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  /// Registers a new account. On success saves the token and returns [User].
  Future<User> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post(
        kRegisterEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      await ApiClient.saveToken(data['token'] as String);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  /// Calls POST /api/logout and clears the local token.
  Future<void> logout() async {
    try {
      await _dio.post(kLogoutEndpoint);
    } catch (_) {
      // Even if server call fails, clear local token
    } finally {
      await ApiClient.deleteToken();
    }
  }

  /// Fetches the currently authenticated user from GET /api/me.
  Future<User> getMe() async {
    try {
      final response = await _dio.get(kMeEndpoint);
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
