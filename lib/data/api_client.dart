import 'dart:io';

import 'package:currency_converter/core/consts/api_key.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';

class ApiClient {
  Future<dio.Dio> dioCore;

  ApiClient({
    required this.dioCore,
  });

  static ApiClient getInstance() {
    return ApiClient(
      dioCore: _dioCore(),
    );
  }

  static Future<dio.Dio> _dioCore({Map<String, dynamic>? headers}) async {
    return dio.Dio(dio.BaseOptions(
      baseUrl: ApiKey.getBaseUrl(),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'apikey': ApiKey.getApiKey(),
      }..addAll(headers ?? {}),
    ))
      ..interceptors.addAll([
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler.next(options); //continue
          },
          onResponse: (response, handler) async {
            return handler.next(response); // continue
          },
          onError: (DioError e, handler) async {
            if (e.type == DioErrorType.other) {
              if (e.error is SocketException) {}
            } else {
              return handler.next(e); //continue
            }
          },
        ),
      ]);
  }
}
