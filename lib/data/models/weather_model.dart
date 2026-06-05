// ignore_for_file: avoid_print

// ─── Helpers ─────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _toStr(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

bool _computeIsDay(Map<String, dynamic> c) {
  final timeStr = c['time']?.toString() ?? '';
  final dt = DateTime.tryParse(timeStr) ?? DateTime.now();
  final hour = dt.hour;

  if (hour >= 20 || hour < 6) return false;
  if (hour >= 7 && hour < 18) return true;

  // Dawn/dusk — fall back to API value
  return _toInt(c['is_day'] ?? 1) == 1;
}

// ─── Current ─────────────────────────────────────────────────────────────────

class CurrentWeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;
  final double uvIndex;
  final double precipitation;
  final int visibility;
  final String time;

  const CurrentWeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.uvIndex,
    required this.precipitation,
    required this.visibility,
    required this.time,
  });

  factory CurrentWeatherModel.fromJson(dynamic raw) {
    final c = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return CurrentWeatherModel(
      temperature: _toDouble(
          c['temp'] ?? c['temperature'] ?? c['temperature_2m'] ?? c['temp_c']),
      feelsLike: _toDouble(
          c['feels_like'] ?? c['feelsLike'] ?? c['apparent_temperature']),
      humidity: _toInt(
          c['humidity'] ?? c['humidity_pct'] ?? c['relative_humidity_2m']),
      windSpeed: _toDouble(
          c['wind'] ?? c['wind_kph'] ?? c['wind_speed'] ?? c['wind_speed_10m']),
      weatherCode: _toInt(
          c['weather_code'] ?? c['weathercode'] ?? c['weatherCode'] ?? 0),
      isDay: _computeIsDay(c),
      uvIndex: _toDouble(c['uv_index'] ?? c['uvIndex']),
      precipitation: _toDouble(c['precipitation']),
      visibility:
          _toInt(c['visibility']) == 0 ? 10000 : _toInt(c['visibility']),
      time: _toStr(c['time'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// ─── Daily ───────────────────────────────────────────────────────────────────

class DailyForecastModel {
  final String date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipitationProbability;
  final double uvIndexMax;
  final String sunrise;
  final String sunset;

  const DailyForecastModel({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyForecastModel.fromMap(dynamic d) {
    final m = d is Map<String, dynamic> ? d : <String, dynamic>{};
    return DailyForecastModel(
      date: _toStr(m['date'] ?? m['day'] ?? m['time'] ?? m['dt_txt']),
      tempMax: _toDouble(m['high'] ??
          m['max'] ??
          m['temp_max'] ??
          m['temperature_max'] ??
          m['maxtemp_c'] ??
          m['temperature_2m_max']),
      tempMin: _toDouble(m['low'] ??
          m['min'] ??
          m['temp_min'] ??
          m['temperature_min'] ??
          m['mintemp_c'] ??
          m['temperature_2m_min']),
      weatherCode: _toInt(
          m['weather_code'] ?? m['weathercode'] ?? m['weatherCode'] ?? 0),
      precipitationProbability: _toDouble(m['pop'] ??
          m['precip_probability'] ??
          m['chance_of_rain'] ??
          m['precipitation_probability_max'] ??
          m['precipitation_probability']),
      uvIndexMax:
          _toDouble(m['uv_index_max'] ?? m['uvIndex'] ?? m['uv_index']),
      sunrise: _toStr(m['sunrise']),
      sunset: _toStr(m['sunset']),
    );
  }

  static List<DailyForecastModel> listFromJson(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map(DailyForecastModel.fromMap).toList();
    if (raw is Map<String, dynamic>) {
      final times = raw['time'];
      if (times is List) {
        return List.generate(times.length, (i) {
          dynamic get(String key) {
            final v = raw[key];
            return v is List && i < v.length ? v[i] : null;
          }

          return DailyForecastModel(
            date: _toStr(times[i]),
            tempMax: _toDouble(get('temperature_2m_max') ?? get('temp_max')),
            tempMin: _toDouble(get('temperature_2m_min') ?? get('temp_min')),
            weatherCode:
                _toInt(get('weather_code') ?? get('weathercode')),
            precipitationProbability: _toDouble(
                get('precipitation_probability_max') ?? get('pop')),
            uvIndexMax: _toDouble(get('uv_index_max')),
            sunrise: _toStr(get('sunrise')),
            sunset: _toStr(get('sunset')),
          );
        });
      }
    }
    return [];
  }
}

// ─── Hourly ──────────────────────────────────────────────────────────────────

class HourlyForecastModel {
  final String time;
  final double temperature;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final double precipitation;

  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  factory HourlyForecastModel.fromMap(dynamic h) {
    final m = h is Map<String, dynamic> ? h : <String, dynamic>{};
    return HourlyForecastModel(
      time: _toStr(m['time'] ?? m['dt_txt'] ?? m['hour']),
      temperature: _toDouble(
          m['temp'] ?? m['temperature'] ?? m['temp_c'] ?? m['temperature_2m']),
      weatherCode: _toInt(
          m['weather_code'] ?? m['weathercode'] ?? m['weatherCode'] ?? 0),
      humidity: _toInt(
          m['humidity'] ?? m['humidity_pct'] ?? m['relative_humidity_2m']),
      windSpeed: _toDouble(
          m['wind'] ?? m['wind_kph'] ?? m['wind_speed'] ?? m['wind_speed_10m']),
      precipitation: _toDouble(m['precipitation'] ?? m['pop']),
    );
  }

  static List<HourlyForecastModel> listFromJson(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map(HourlyForecastModel.fromMap).toList();
    if (raw is Map<String, dynamic>) {
      final times = raw['time'];
      if (times is List) {
        return List.generate(times.length, (i) {
          dynamic get(String key) {
            final v = raw[key];
            return v is List && i < v.length ? v[i] : null;
          }

          return HourlyForecastModel(
            time: _toStr(times[i]),
            temperature:
                _toDouble(get('temperature_2m') ?? get('temperature')),
            weatherCode:
                _toInt(get('weather_code') ?? get('weathercode')),
            humidity:
                _toInt(get('relative_humidity_2m') ?? get('humidity')),
            windSpeed:
                _toDouble(get('wind_speed_10m') ?? get('wind_speed')),
            precipitation: _toDouble(get('precipitation')),
          );
        });
      }
    }
    return [];
  }
}

// ─── Response ────────────────────────────────────────────────────────────────

class WeatherResponseModel {
  final CurrentWeatherModel current;
  final List<DailyForecastModel> daily;
  final List<HourlyForecastModel> hourly;
  final String? aiSummary;
  final double latitude;
  final double longitude;
  final String? timezone;
  final String? locationName;

  const WeatherResponseModel({
    required this.current,
    required this.daily,
    required this.hourly,
    this.aiSummary,
    required this.latitude,
    required this.longitude,
    this.timezone,
    this.locationName,
  });

  factory WeatherResponseModel.fromJson(dynamic rawJson, String? cityName) {
    try {
      Map<String, dynamic> json;
      if (rawJson is List && rawJson.isNotEmpty) {
        json = rawJson.first is Map<String, dynamic>
            ? rawJson.first as Map<String, dynamic>
            : {};
      } else if (rawJson is Map<String, dynamic>) {
        json = rawJson;
      } else {
        print('[MODEL] Unexpected type: ${rawJson.runtimeType}');
        json = {};
      }

      print('[MODEL] Top-level keys: ${json.keys.toList()}');
      print('[MODEL] current type: ${json['current'].runtimeType}');
      print('[MODEL] daily type: ${json['daily'].runtimeType}');
      print('[MODEL] hourly type: ${json['hourly'].runtimeType}');

      // Extract location name — can be a String OR a Map
      String? locationFromApi;
      final locationRaw = json['location'];
      if (locationRaw is String) {
        locationFromApi = locationRaw;
      } else if (locationRaw is Map) {
        locationFromApi = _toStr(locationRaw['name'] ??
            locationRaw['city'] ??
            locationRaw['locality']);
        if (locationFromApi!.isEmpty) locationFromApi = null;
      }

      // lat/lon can also be nested inside location map
      double lat = _toDouble(json['latitude'] ?? json['lat']);
      double lon = _toDouble(json['longitude'] ?? json['lon']);
      if (lat == 0.0 && locationRaw is Map) {
        lat = _toDouble(locationRaw['lat'] ?? locationRaw['latitude']);
        lon = _toDouble(locationRaw['lon'] ?? locationRaw['longitude']);
      }

      // AI summary
      final aiSummary = json['ai_summary'] as String? ??
          json['summary'] as String? ??
          json['aiSummary'] as String? ??
          json['insights'] as String? ??
          (json['ai'] is Map
              ? _toStr((json['ai'] as Map)['summary'])
              : null);

      return WeatherResponseModel(
        current: CurrentWeatherModel.fromJson(json['current'] ?? json),
        daily: DailyForecastModel.listFromJson(json['daily']),
        hourly: HourlyForecastModel.listFromJson(json['hourly']),
        aiSummary: aiSummary?.isNotEmpty == true ? aiSummary : null,
        latitude: lat,
        longitude: lon,
        timezone: json['timezone'] as String?,
        locationName: cityName ?? locationFromApi,
      );
    } catch (e, stack) {
      print('[MODEL] Parse error: $e');
      print('[MODEL] Stack: $stack');
      rethrow;
    }
  }
}