import 'package:dio/dio.dart';
import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.apiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          assert(() {
            // ignore: avoid_print
            print('[API] ${options.method} ${options.path} params:${options.queryParameters}');
            return true;
          }());
          handler.next(options);
        },
        onError: (error, handler) {
          // ignore: avoid_print
          print('[API ERROR] status: ${error.response?.statusCode}');
          // ignore: avoid_print
          print('[API ERROR] data: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
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
        final message = body is Map
            ? (body['message'] ?? body['error'] ?? 'Server error')
            : 'Server error ($statusCode)';
        return ServerException(message.toString(), statusCode: statusCode);
      default:
        return ServerException(e.message ?? 'An unexpected error occurred.');
    }
  }
}