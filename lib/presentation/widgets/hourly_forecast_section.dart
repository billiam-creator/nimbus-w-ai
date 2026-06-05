import 'package:flutter/material.dart';
import 'package:nimbus/core/utils/weather_utils.dart';
import 'package:nimbus/data/models/weather_model.dart';

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
    final upcoming = hourly.where((h) {
      final dt = DateTime.tryParse(h.time);
      if (dt == null) return false;
      return dt.isAfter(now.subtract(const Duration(hours: 1))) &&
          dt.isBefore(now.add(const Duration(hours: 24)));
    }).take(24).toList();

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final tempUnit = units == 'metric' ? '°' : '°';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF142038) : Colors.white;
    final activeCardColor =
        isDark ? const Color(0xFF1E4D8C) : const Color(0xFFE3F2FD);
    final activeBorderColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3);
    final activeTextColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);
    final inactiveTextColor = isDark ? Colors.white54 : Colors.black45;
    final tempTextColor = isDark ? Colors.white : Colors.black87;

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
              final dt = DateTime.tryParse(hour.time);
              final isDayHour =
                  dt != null ? (dt.hour >= 6 && dt.hour < 19) : true;

              return Container(
                width: 68,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isNow ? activeCardColor : cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isNow
                      ? Border.all(color: activeBorderColor, width: 1.5)
                      : null,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isNow ? 'Now' : WeatherUtils.formatHour(hour.time),
                      style: TextStyle(
                        color: isNow ? activeTextColor : inactiveTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      WeatherUtils.codeToEmoji(hour.weatherCode,
                          isDay: isDayHour),
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${hour.temperature.round()}$tempUnit',
                      style: TextStyle(
                        color: tempTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}