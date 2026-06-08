import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nimbus/data/models/weather_model.dart';

enum AlertLevel { info, warning, danger }

class WeatherAlert {
  final String emoji;
  final String title;
  final String message;
  final AlertLevel level;

  const WeatherAlert({
    required this.emoji,
    required this.title,
    required this.message,
    required this.level,
  });
}

class WeatherAlertBanner extends StatelessWidget {
  final WeatherResponseModel weather;
  final String units;

  const WeatherAlertBanner({
    super.key,
    required this.weather,
    required this.units,
  });

  List<WeatherAlert> _getAlerts() {
    final alerts = <WeatherAlert>[];
    final current = weather.current;
    final code = current.weatherCode;
    final temp = current.temperature;
    final isMetric = units == 'metric';

    // ── Weather code alerts ───────────────────────────────────────────
    if (code >= 95) {
      alerts.add(const WeatherAlert(
        emoji: '⛈️',
        title: 'Thunderstorm Warning',
        message: 'Severe thunderstorm with possible lightning and hail. Stay indoors.',
        level: AlertLevel.danger,
      ));
    } else if (code >= 80 && code <= 94) {
      alerts.add(const WeatherAlert(
        emoji: '🌧️',
        title: 'Heavy Rain Showers',
        message: 'Intense rain showers expected. Carry an umbrella and avoid flooded areas.',
        level: AlertLevel.warning,
      ));
    } else if (code >= 65 && code <= 69) {
      alerts.add(const WeatherAlert(
        emoji: '🌧️',
        title: 'Heavy Rain',
        message: 'Heavy rainfall in your area. Risk of localised flooding.',
        level: AlertLevel.warning,
      ));
    } else if (code >= 71 && code <= 79) {
      alerts.add(const WeatherAlert(
        emoji: '🌨️',
        title: 'Snowfall Alert',
        message: 'Significant snowfall expected. Roads may be slippery — drive carefully.',
        level: AlertLevel.warning,
      ));
    } else if (code >= 45 && code <= 49) {
      alerts.add(const WeatherAlert(
        emoji: '🌫️',
        title: 'Dense Fog Advisory',
        message: 'Low visibility due to dense fog. Drive slowly and use fog lights.',
        level: AlertLevel.info,
      ));
    }

    // ── Temperature alerts ────────────────────────────────────────────
    if (isMetric) {
      if (temp >= 38) {
        alerts.add(WeatherAlert(
          emoji: '🔥',
          title: 'Extreme Heat Warning',
          message:
              'Temperature is ${temp.round()}°C — dangerously hot. Stay hydrated, avoid direct sun, and check on elderly neighbours.',
          level: AlertLevel.danger,
        ));
      } else if (temp >= 33) {
        alerts.add(WeatherAlert(
          emoji: '☀️',
          title: 'Heat Advisory',
          message:
              'Temperature is ${temp.round()}°C. Drink plenty of water and limit outdoor activity between 11am–3pm.',
          level: AlertLevel.warning,
        ));
      } else if (temp <= -10) {
        alerts.add(WeatherAlert(
          emoji: '🥶',
          title: 'Extreme Cold Warning',
          message:
              'Temperature is ${temp.round()}°C — dangerously cold. Risk of frostbite. Wear heavy layers and limit time outdoors.',
          level: AlertLevel.danger,
        ));
      } else if (temp <= 0) {
        alerts.add(WeatherAlert(
          emoji: '🧊',
          title: 'Freezing Conditions',
          message:
              'Temperature is ${temp.round()}°C. Ice may form on roads and pavements — take extra care.',
          level: AlertLevel.warning,
        ));
      }
    } else {
      // Imperial
      if (temp >= 100) {
        alerts.add(WeatherAlert(
          emoji: '🔥',
          title: 'Extreme Heat Warning',
          message:
              'Temperature is ${temp.round()}°F — dangerously hot. Stay hydrated and avoid direct sun.',
          level: AlertLevel.danger,
        ));
      } else if (temp >= 90) {
        alerts.add(WeatherAlert(
          emoji: '☀️',
          title: 'Heat Advisory',
          message:
              'Temperature is ${temp.round()}°F. Drink plenty of water and limit midday outdoor activity.',
          level: AlertLevel.warning,
        ));
      } else if (temp <= 14) {
        alerts.add(WeatherAlert(
          emoji: '🥶',
          title: 'Extreme Cold Warning',
          message:
              'Temperature is ${temp.round()}°F — dangerously cold. Risk of frostbite. Wear heavy layers.',
          level: AlertLevel.danger,
        ));
      } else if (temp <= 32) {
        alerts.add(WeatherAlert(
          emoji: '🧊',
          title: 'Freezing Conditions',
          message:
              'Temperature is ${temp.round()}°F. Ice may form on roads — take extra care.',
          level: AlertLevel.warning,
        ));
      }
    }

    // ── UV Index alerts ───────────────────────────────────────────────
    if (current.uvIndex >= 11) {
      alerts.add(WeatherAlert(
        emoji: '🕶️',
        title: 'Extreme UV Index',
        message:
            'UV index is ${current.uvIndex.round()} — extreme. Apply SPF 50+, wear protective clothing and avoid being outside midday.',
        level: AlertLevel.danger,
      ));
    } else if (current.uvIndex >= 8) {
      alerts.add(WeatherAlert(
        emoji: '🕶️',
        title: 'Very High UV Index',
        message:
            'UV index is ${current.uvIndex.round()}. Apply sunscreen and wear a hat if going outside.',
        level: AlertLevel.warning,
      ));
    }

    // ── Wind alerts ───────────────────────────────────────────────────
    final windKph = isMetric ? current.windSpeed : current.windSpeed * 1.609;
    if (windKph >= 90) {
      alerts.add(WeatherAlert(
        emoji: '🌀',
        title: 'Storm Force Winds',
        message:
            'Wind speeds of ${current.windSpeed.round()} ${isMetric ? 'km/h' : 'mph'}. Dangerous conditions — stay indoors.',
        level: AlertLevel.danger,
      ));
    } else if (windKph >= 50) {
      alerts.add(WeatherAlert(
        emoji: '💨',
        title: 'Strong Wind Advisory',
        message:
            'Wind speeds of ${current.windSpeed.round()} ${isMetric ? 'km/h' : 'mph'}. Secure loose objects and take care outdoors.',
        level: AlertLevel.warning,
      ));
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _getAlerts();
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.asMap().entries.map((entry) {
        return _AlertCard(
          alert: entry.value,
          index: entry.key,
        );
      }).toList(),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final WeatherAlert alert;
  final int index;

  const _AlertCard({required this.alert, required this.index});

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _dismissed = false;

  Color get _bgColor {
    switch (widget.alert.level) {
      case AlertLevel.danger:
        return const Color(0xFF7F0000);
      case AlertLevel.warning:
        return const Color(0xFF4A2800);
      case AlertLevel.info:
        return const Color(0xFF003060);
    }
  }

  Color get _borderColor {
    switch (widget.alert.level) {
      case AlertLevel.danger:
        return const Color(0xFFEF5350);
      case AlertLevel.warning:
        return const Color(0xFFFFB300);
      case AlertLevel.info:
        return const Color(0xFF42A5F5);
    }
  }

  Color get _tagColor {
    switch (widget.alert.level) {
      case AlertLevel.danger:
        return const Color(0xFFEF5350);
      case AlertLevel.warning:
        return const Color(0xFFFFB300);
      case AlertLevel.info:
        return const Color(0xFF42A5F5);
    }
  }

  String get _tagLabel {
    switch (widget.alert.level) {
      case AlertLevel.danger:
        return 'DANGER';
      case AlertLevel.warning:
        return 'WARNING';
      case AlertLevel.info:
        return 'ADVISORY';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.alert.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tagColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _tagColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          _tagLabel,
                          style: TextStyle(
                            color: _tagColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.alert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.alert.message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close, color: Colors.white38, size: 16),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (widget.index * 100).ms).slideY(begin: -0.1, end: 0);
  }
}