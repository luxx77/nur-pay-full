import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app_role.dart';
import '../session/session.dart';
import 'api_error_code.dart';
import 'api_exception.dart';
import 'network_error_bus.dart';

/// HTTP-клиент Nur Pay.
///
/// Складывает заголовки авторизации и переводит любой сбой в
/// [ApiException] — выше по стеку про dio больше никто не знает.
class ApiClient {
  ApiClient({required String baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              contentType: Headers.jsonContentType,
              // Разбираем статус сами: ошибку надо прочитать, а не
              // получить голое исключение без тела.
              validateStatus: (_) => true,
            ),
          );

  /// Адрес бэкенда. Переопределяется значением NURPAY_API_URL —
  /// сначала смотрим в --dart-define (явный override для конкретного
  /// запуска/сборки), затем в .env (подхватывается через dotenv.load()
  /// в main — его достаточно для обычного `flutter run` на реальном
  /// устройстве в одной сети с компьютером).
  ///
  /// Без переопределения угадываем по платформе: у Android-эмулятора
  /// localhost хоста — это 10.0.2.2, а не localhost. На остальных целях
  /// отладки (macOS, web, iOS-симулятор) сервер поднят на этой же
  /// машине, туда и обычный localhost достаёт.
  static String get defaultBaseUrl {
    const override = String.fromEnvironment('NURPAY_API_URL');
    if (override.isNotEmpty) return override;
    final fromDotenv = dotenv.maybeGet('NURPAY_API_URL');
    if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  final Dio _dio;

  /// Текущая сессия. Пока её нет, заголовки не отправляются.
  Session? session;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) => _send(
    () => _dio.post<dynamic>(
      path,
      data: body,
      options: Options(headers: headers),
    ),
  );

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    final Response<dynamic> response;
    try {
      response = await _withAuth(request);
    } on DioException {
      const error = ApiException.network();
      NetworkErrorBus.instance.add(error);
      throw error;
    }

    final data = response.data;
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300) {
      return data is Map<String, dynamic> ? data : const {};
    }

    // Ошибка всегда приходит в одном формате: {code, message}.
    if (data is Map<String, dynamic> && data['code'] is String) {
      throw ApiException(
        code: data['code'] as String,
        message: data['message'] as String? ?? '',
        statusCode: status,
      );
    }

    throw ApiException(
      code: ApiErrorCode.internal,
      message: 'unexpected response',
      statusCode: status,
    );
  }

  Future<Response<dynamic>> _withAuth(
    Future<Response<dynamic>> Function() request,
  ) {
    final current = session;
    if (current == null) {
      _dio.options.headers.remove('user_id');
      _dio.options.headers.remove('user_type');
    } else {
      _dio.options.headers['user_id'] = current.userId;
      _dio.options.headers['user_type'] = current.role.apiValue;
    }
    return request();
  }
}
