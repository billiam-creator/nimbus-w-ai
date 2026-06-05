import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nimbus/core/utils/weather_utils.dart';
import 'package:nimbus/data/models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherResponseModel weather;
  final String locationLabel;
  final String units;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    required this.locationLabel,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final tempUnit = units == 'metric' ? '°C' : '°F';
    final code = current.weatherCode;
    final isDay = current.isDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: WeatherUtils.backgroundColors(code, isDay)
              .map((c) => Color(c))
              .toList(),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  locationLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Weather emoji — now day/night aware
          Text(
  WeatherUtils.codeToEmoji(code, isDay: isDay),
            style: const TextStyle(fontSize: 80),
          ).animate().scale(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Temperature
          Text(
            '${current.temperature.round()}$tempUnit',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              letterSpacing: -3,
            ),
          ).animate().fadeIn(delay: 300.ms),

          // Description — now day/night aware
          Text(
            WeatherUtils.codeToDescription(code, isDay: isDay),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 8),

          Text(
            'Feels like ${current.feelsLike.round()}$tempUnit',
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ).animate().fadeIn(delay: 450.ms),

          const SizedBox(height: 32),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(
                icon: Icons.water_drop_outlined,
                label: '${current.humidity}%',
                sublabel: 'Humidity',
              ),
              _StatChip(
                icon: Icons.air,
                label:
                    '${current.windSpeed.round()} ${units == 'metric' ? 'km/h' : 'mph'}',
                sublabel: 'Wind',
              ),
              _StatChip(
                icon: Icons.wb_sunny_outlined,
                label: 'UV ${current.uvIndex.round()}',
                sublabel: 'Index',
              ),
            ],
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            sublabel,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}