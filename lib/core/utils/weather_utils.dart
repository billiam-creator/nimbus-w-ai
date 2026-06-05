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

  /// Day/night aware emoji — isDay matters for clear/partly cloudy
  static String codeToEmoji(int? code, {bool isDay = true}) {
    if (code == null) return '🌡️';
    if (code == 0) return isDay ? '☀️' : '🌙';           // clear
    if (code == 1) return isDay ? '🌤️' : '🌙';           // mainly clear
    if (code == 2) return isDay ? '⛅' : '☁️';            // partly cloudy
    if (code == 3) return '☁️';                            // overcast (same day/night)
    if (code <= 49) return isDay ? '🌫️' : '🌫️';         // fog
    if (code <= 59) return '🌦️';                          // drizzle
    if (code <= 69) return '🌧️';                          // rain
    if (code <= 79) return '🌨️';                          // snow
    if (code <= 84) return '🌦️';                          // showers
    if (code <= 94) return '⛈️';                          // thunderstorm
    return '⛈️';
  }

  /// Day/night aware description
  static String codeToDescription(int? code, {bool isDay = true}) {
    if (code == null) return 'Unknown';
    if (code == 0) return isDay ? 'Clear Sky' : 'Clear Night';
    if (code == 1) return isDay ? 'Mainly Clear' : 'Mainly Clear';
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

  /// Background gradient based on weather code + time of day
  static List<int> backgroundColors(int? code, bool isDay) {
    if (!isDay) {
      // Night — always dark regardless of condition
      if (code != null && code >= 50 && code <= 69) {
        return [0xFF0D1B2A, 0xFF1B2838]; // rainy night
      }
      if (code != null && code >= 70 && code <= 79) {
        return [0xFF1A1A2E, 0xFF16213E]; // snowy night
      }
      if (code != null && code >= 80) {
        return [0xFF0D1117, 0xFF1A1A2E]; // stormy night
      }
      return [0xFF0D1B2A, 0xFF1B2A4A]; // clear/cloudy night
    }
    // Daytime
    if (code == null || code <= 1) return [0xFF1E90FF, 0xFF87CEEB]; // sunny
    if (code == 2) return [0xFF4A90D9, 0xFF87CEEB];                  // partly cloudy
    if (code == 3) return [0xFF607D8B, 0xFF90A4AE];                  // overcast
    if (code <= 49) return [0xFF546E7A, 0xFF78909C];                 // fog
    if (code <= 59) return [0xFF546E7A, 0xFF607D8B];                 // drizzle
    if (code <= 69) return [0xFF37474F, 0xFF546E7A];                 // rain
    if (code <= 79) return [0xFF455A64, 0xFF607D8B];                 // snow
    return [0xFF263238, 0xFF37474F];                                  // storm
  }
}