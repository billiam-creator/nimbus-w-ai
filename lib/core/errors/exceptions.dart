abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection.'])
      : super(message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(String message, {this.statusCode}) : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Invalid API key. Check your .env file.');
}

class RateLimitException extends AppException {
  const RateLimitException() : super('Monthly quota exceeded. Upgrade your plan.');
}

class LocationException extends AppException {
  const LocationException([String message = 'Unable to get your location.'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'No cached data available.'])
      : super(message);
}
