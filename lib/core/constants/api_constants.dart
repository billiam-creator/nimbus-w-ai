class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.weather-ai.co';
  static const String weatherEndpoint = '/v1/weather';
  static const String currentEndpoint = '/v1/current';
  static const String forecastEndpoint = '/v1/forecast';
  static const String geoWeatherEndpoint = '/v1/weather-geo';
  static const String usageEndpoint = '/v1/usage';

  // Default params
  static const String defaultUnits = 'metric';
  static const int defaultForecastDays = 7;
}
