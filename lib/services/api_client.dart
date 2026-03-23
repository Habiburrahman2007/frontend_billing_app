import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/error/api_exception.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;

  static const _tokenKey = 'auth_token';
  static final _storage = FlutterSecureStorage();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // 1. Auth token injector
    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          final response = e.response;
          if (response != null) {
            final data = response.data;
            final message = (data is Map && data['message'] != null)
                ? data['message'].toString()
                : 'Server error (${response.statusCode})';
            final errors =
                (data is Map && data['errors'] != null) ? data['errors'] as Map<String, dynamic> : null;
            handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: ApiException(
                  message: message,
                  errors: errors,
                  statusCode: response.statusCode,
                ),
                response: response,
                type: e.type,
              ),
            );
            return;
          }
          handler.next(e);
        },
      ),
    );

    // 2. Retry on connection errors (not on 4xx)
    d.interceptors.add(
      RetryInterceptor(
        dio: d,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    return d;
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<bool> hasToken() async {
    final t = await _storage.read(key: _tokenKey);
    return t != null && t.isNotEmpty;
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  /// Unwraps the DioException error into an [ApiException] if possible,
  /// otherwise creates a generic one from the message.
  static ApiException toApiException(Object e) {
    if (e is DioException) {
      if (e.error is ApiException) return e.error as ApiException;
      return ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(message: e.toString());
  }
}
