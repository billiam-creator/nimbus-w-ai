abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection. Please check your network and try again.'])
      : super(message);
}

class TimeoutException extends AppException {
  const TimeoutException()
      : super('Request timed out. Your connection may be slow — please try again.');
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(String message, {this.statusCode}) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Invalid API key. Please check your configuration.');
}

class RateLimitException extends AppException {
  const RateLimitException()
      : super('Monthly request quota exceeded. Please upgrade your plan.');
}

class LocationException extends AppException {
  const LocationException([String message = 'Unable to get your location. Please enable location permissions.'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'No cached data available.'])
      : super(message);
}