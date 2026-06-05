import 'package:intl/intl.dart';

class WeatherUtils {
  WeatherUtils._();

  static String formatDate(String isoDate) {
    final dt = DateTime.tryParse(isoDate) ?? DateTime.now();
    return DateFormat('EEE, MMM d').format(dt);
  }

  static String formatShortDay(String isoDate) {
    final dt = DateTime.tryParse(isoDate) ?? DateTime.now();
    return DateFormat('EEE').format(dt);
  }

  static String formatHour(String isoDate) {
    final dt = DateTime.tryParse(isoDate) ?? DateTime.now();
    return DateFormat('h a').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  /// Map WMO weather code to emoji icon
  static String codeToEmoji(int? code) {
    if (code == null) return '🌡️';
    if (code == 0) return '☀️';
    if (code <= 2) return '⛅';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️'; // fog
    if (code <= 59) return '🌦️'; // drizzle
    if (code <= 69) return '🌧️'; // rain
    if (code <= 79) return '🌨️'; // snow
    if (code <= 84) return '🌦️'; // showers
    if (code <= 94) return '⛈️'; // thunderstorm
    return '⛈️';
  }

  /// Map WMO code to description
  static String codeToDescription(int? code) {
    if (code == null) return 'Unknown';
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rainy';
    if (code <= 79) return 'Snowy';
    if (code <= 84) return 'Rain Showers';
    if (code <= 94) return 'Thunderstorm';
    return 'Severe Storm';
  }

  /// Background gradient based on weather code + time
  static List<int> backgroundColors(int? code, bool isDay) {
    if (!isDay) return [0xFF0D1B2A, 0xFF1B2A4A]; // night
    if (code == null || code == 0 || code <= 2) {
      return [0xFF1E90FF, 0xFF87CEEB]; // sunny/clear
    }
    if (code <= 3) return [0xFF607D8B, 0xFF90A4AE]; // cloudy
    if (code <= 59) return [0xFF546E7A, 0xFF78909C]; // drizzle/fog
    if (code <= 69) return [0xFF37474F, 0xFF546E7A]; // rain
    return [0xFF263238, 0xFF37474F]; // storm/snow
  }
}
