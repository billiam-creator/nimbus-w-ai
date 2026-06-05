import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get apiKey => dotenv.env['WEATHER_AI_KEY'] ?? '';
  static const String baseUrl = 'https://api.weather-ai.co';
  static const String weatherEndpoint = '/v1/weather';
  static const String forecastEndpoint = '/v1/forecast';
  static const String currentEndpoint = '/v1/current';
  static const String geoWeatherEndpoint = '/v1/weather-geo';
  static const String defaultUnits = 'metric';
  static const int defaultForecastDays = 7;
}