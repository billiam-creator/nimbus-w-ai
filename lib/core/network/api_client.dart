import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skycast/core/constants/api_constants.dart';
import 'package:skycast/core/errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['WEATHER_AI_KEY']}',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log requests in debug
          assert(() {
            // ignore: avoid_print
            print('[API] ${options.method} ${options.path} params:${options.queryParameters}');
            return true;
          }());
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
        print('[API ERROR] status: ${error.response?.statusCode}');
        print('[API ERROR] data: ${error.response?.data}');
        print('[API ERROR] url: ${error.requestOptions.uri}');
  handler.next(error);
},
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException('Request timed out. Check your connection.');
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final body = e.response?.data;
        if (statusCode == 401) return const UnauthorizedException();
        if (statusCode == 429) return const RateLimitException();
        final message = body is Map ? (body['message'] ?? 'Server error') : 'Server error';
        return ServerException(message.toString(), statusCode: statusCode);
      default:
        return ServerException(e.message ?? 'An unexpected error occurred.');
    }
  }
}
