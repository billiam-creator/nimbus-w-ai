import 'package:flutter/material.dart';
import 'package:skycast/core/utils/weather_utils.dart';
import 'package:skycast/data/models/weather_model.dart';

class HourlyForecastSection extends StatelessWidget {
  final List<HourlyForecastModel> hourly;
  final String units;

  const HourlyForecastSection({
    super.key,
    required this.hourly,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show next 24 hours only
    final upcoming = hourly.where((h) {
      final dt = DateTime.tryParse(h.time);
      if (dt == null) return false;
      return dt.isAfter(now.subtract(const Duration(hours: 1))) &&
          dt.isBefore(now.add(const Duration(hours: 24)));
    }).take(24).toList();

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final tempUnit = units == 'metric' ? '°' : '°';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'HOURLY',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              final hour = upcoming[index];
              final isNow = index == 0;
              return _HourChip(
                hour: hour,
                tempUnit: tempUnit,
                isNow: isNow,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourChip extends StatelessWidget {
  final HourlyForecastModel hour;
  final String tempUnit;
  final bool isNow;

  const _HourChip({
    required this.hour,
    required this.tempUnit,
    required this.isNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isNow
            ? const Color(0xFF1E4D8C)
            : const Color(0xFF142038),
        borderRadius: BorderRadius.circular(16),
        border: isNow
            ? Border.all(color: const Color(0xFF64B5F6), width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isNow ? 'Now' : WeatherUtils.formatHour(hour.time),
            style: TextStyle(
              color: isNow ? const Color(0xFF64B5F6) : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WeatherUtils.codeToEmoji(hour.weatherCode),
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            '${hour.temperature.round()}$tempUnit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
