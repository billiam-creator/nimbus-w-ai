import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/core/errors/exceptions.dart';
import 'package:skycast/core/errors/result.dart';
import 'package:skycast/data/models/weather_model.dart';

void main() {
  group('Result<T>', () {
    test('Success carries data', () {
      const result = Success(42);
      expect(result.isSuccess, true);
      expect(result.dataOrNull, 42);
    });

    test('Failure carries exception', () {
      const result = Failure<int>(NetworkException());
      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<NetworkException>());
    });

    test('when() dispatches correctly', () {
      const Result<String> r = Success('hello');
      final output = r.when(
        success: (d) => 'got: $d',
        failure: (e) => 'err: ${e.message}',
      );
      expect(output, 'got: hello');
    });
  });

  group('WeatherResponseModel.fromJson', () {
    test('parses minimal valid response', () {
      final json = {
        'latitude': -1.2921,
        'longitude': 36.8219,
        'current': {
          'temperature_2m': 22.5,
          'apparent_temperature': 21.0,
          'relative_humidity_2m': 65,
          'wind_speed_10m': 12.0,
          'weather_code': 1,
          'is_day': 1,
          'uv_index': 3.0,
          'precipitation': 0.0,
          'visibility': 10000,
          'time': '2024-11-01T10:00',
        },
        'daily': {
          'time': ['2024-11-01', '2024-11-02'],
          'temperature_2m_max': [25.0, 23.0],
          'temperature_2m_min': [15.0, 14.0],
          'weather_code': [0, 2],
          'precipitation_probability_max': [0, 20],
          'uv_index_max': [5.0, 4.0],
          'sunrise': ['2024-11-01T06:00', '2024-11-02T06:01'],
          'sunset': ['2024-11-01T18:30', '2024-11-02T18:29'],
        },
        'hourly': {
          'time': ['2024-11-01T10:00', '2024-11-01T11:00'],
          'temperature_2m': [22.0, 23.0],
          'weather_code': [0, 1],
          'relative_humidity_2m': [60, 58],
          'wind_speed_10m': [10.0, 11.0],
          'precipitation': [0.0, 0.0],
        },
        'ai_summary': 'Clear skies expected throughout the day.',
      };

      final model = WeatherResponseModel.fromJson(json, 'Nairobi');

      expect(model.current.temperature, 22.5);
      expect(model.current.humidity, 65);
      expect(model.current.isDay, true);
      expect(model.daily.length, 2);
      expect(model.daily[0].tempMax, 25.0);
      expect(model.hourly.length, 2);
      expect(model.aiSummary, 'Clear skies expected throughout the day.');
      expect(model.locationName, 'Nairobi');
      expect(model.latitude, -1.2921);
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'latitude': 0.0,
        'longitude': 0.0,
        'current': <String, dynamic>{},
        'daily': <String, dynamic>{},
        'hourly': <String, dynamic>{},
      };
      final model = WeatherResponseModel.fromJson(json, null);
      expect(model.current.temperature, 0.0);
      expect(model.daily, isEmpty);
      expect(model.hourly, isEmpty);
      expect(model.aiSummary, isNull);
    });
  });

  group('DailyForecastModel', () {
    test('listFromJson returns correct count', () {
      final daily = {
        'time': ['2024-11-01', '2024-11-02', '2024-11-03'],
        'temperature_2m_max': [25.0, 24.0, 26.0],
        'temperature_2m_min': [15.0, 14.0, 16.0],
        'weather_code': [0, 1, 2],
        'precipitation_probability_max': [0, 10, 20],
        'uv_index_max': [5.0, 4.5, 6.0],
        'sunrise': ['', '', ''],
        'sunset': ['', '', ''],
      };
      final list = DailyForecastModel.listFromJson(daily);
      expect(list.length, 3);
      expect(list[1].tempMax, 24.0);
    });
  });
}
