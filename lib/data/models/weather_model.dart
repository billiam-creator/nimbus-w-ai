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

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? json;
    return CurrentWeatherModel(
      temperature: (current['temperature_2m'] ?? current['temperature'] ?? 0).toDouble(),
      feelsLike: (current['apparent_temperature'] ?? current['feels_like'] ?? 0).toDouble(),
      humidity: (current['relative_humidity_2m'] ?? current['humidity'] ?? 0).toInt(),
      windSpeed: (current['wind_speed_10m'] ?? current['wind_speed'] ?? 0).toDouble(),
      weatherCode: (current['weather_code'] ?? current['weathercode'] ?? 0).toInt(),
      isDay: (current['is_day'] ?? 1) == 1,
      uvIndex: (current['uv_index'] ?? 0).toDouble(),
      precipitation: (current['precipitation'] ?? 0).toDouble(),
      visibility: (current['visibility'] ?? 10000).toInt(),
      time: current['time']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

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

  factory DailyForecastModel.fromJson(Map<String, dynamic> json, int index) {
    List<dynamic> getList(String key) =>
        (json[key] as List<dynamic>?) ?? [];

    final times = getList('time');
    final tempMaxList = getList('temperature_2m_max');
    final tempMinList = getList('temperature_2m_min');
    final codes = getList('weather_code').isNotEmpty
        ? getList('weather_code')
        : getList('weathercode');
    final precipProb = getList('precipitation_probability_max');
    final uvMax = getList('uv_index_max');
    final sunrises = getList('sunrise');
    final sunsets = getList('sunset');

    return DailyForecastModel(
      date: index < times.length ? times[index].toString() : '',
      tempMax: index < tempMaxList.length ? (tempMaxList[index] ?? 0).toDouble() : 0,
      tempMin: index < tempMinList.length ? (tempMinList[index] ?? 0).toDouble() : 0,
      weatherCode: index < codes.length ? (codes[index] ?? 0).toInt() : 0,
      precipitationProbability: index < precipProb.length ? (precipProb[index] ?? 0).toDouble() : 0,
      uvIndexMax: index < uvMax.length ? (uvMax[index] ?? 0).toDouble() : 0,
      sunrise: index < sunrises.length ? sunrises[index].toString() : '',
      sunset: index < sunsets.length ? sunsets[index].toString() : '',
    );
  }

  static List<DailyForecastModel> listFromJson(Map<String, dynamic> daily) {
    final times = (daily['time'] as List<dynamic>?) ?? [];
    return List.generate(
      times.length,
      (i) => DailyForecastModel.fromJson(daily, i),
    );
  }
}

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

  factory HourlyForecastModel.fromJson(Map<String, dynamic> hourly, int index) {
    List<dynamic> getList(String key) => (hourly[key] as List<dynamic>?) ?? [];

    final times = getList('time');
    final temps = getList('temperature_2m');
    final codes = getList('weather_code').isNotEmpty
        ? getList('weather_code')
        : getList('weathercode');
    final humidity = getList('relative_humidity_2m');
    final wind = getList('wind_speed_10m');
    final precip = getList('precipitation');

    return HourlyForecastModel(
      time: index < times.length ? times[index].toString() : '',
      temperature: index < temps.length ? (temps[index] ?? 0).toDouble() : 0,
      weatherCode: index < codes.length ? (codes[index] ?? 0).toInt() : 0,
      humidity: index < humidity.length ? (humidity[index] ?? 0).toInt() : 0,
      windSpeed: index < wind.length ? (wind[index] ?? 0).toDouble() : 0,
      precipitation: index < precip.length ? (precip[index] ?? 0).toDouble() : 0,
    );
  }

  static List<HourlyForecastModel> listFromJson(Map<String, dynamic> hourly) {
    final times = (hourly['time'] as List<dynamic>?) ?? [];
    return List.generate(
      times.length,
      (i) => HourlyForecastModel.fromJson(hourly, i),
    );
  }
}

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

  factory WeatherResponseModel.fromJson(
      Map<String, dynamic> json, String? cityName) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};

    // AI summary can live at different paths
    final aiSummary = json['ai_summary'] as String? ??
        json['summary'] as String? ??
        (json['ai'] as Map<String, dynamic>?)?['summary'] as String?;

    return WeatherResponseModel(
      current: CurrentWeatherModel.fromJson(currentJson.isNotEmpty
          ? {'current': currentJson}
          : json),
      daily: DailyForecastModel.listFromJson(dailyJson),
      hourly: HourlyForecastModel.listFromJson(hourlyJson),
      aiSummary: aiSummary,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timezone: json['timezone'] as String?,
      locationName: cityName ??
          json['city'] as String? ??
          json['location'] as String?,
    );
  }
}
