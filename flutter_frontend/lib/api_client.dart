import 'dart:io';
import 'package:dio/dio.dart';
import 'services/token_store.dart';

class ApiClient {
  final Dio _dio;
  final TokenStore _store;

  ApiClient(this._store)
      : _dio = Dio(BaseOptions(
          baseUrl: Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://localhost:8000/api',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _store.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await _store.clear();
        }
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await _dio.post('/auth/register', data: {'name': name, 'email': email, 'password': password});
    final token = res.data['token'] as String;
    await _store.saveToken(token);
    return Map<String, dynamic>.from(res.data['user']);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final token = res.data['token'] as String;
    await _store.saveToken(token);
    return Map<String, dynamic>.from(res.data['user']);
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/me');
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _store.clear();
    }
  }
}
