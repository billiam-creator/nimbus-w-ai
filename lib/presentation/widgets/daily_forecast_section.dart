import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nimbus/core/utils/weather_utils.dart';
import 'package:nimbus/data/models/weather_model.dart';

class DailyForecastSection extends StatelessWidget {
  final List<DailyForecastModel> forecast;
  final String units;

  const DailyForecastSection({
    super.key,
    required this.forecast,
    required this.units,
  });

  @override
  Widget build(BuildContext context) {
    final tempUnit = units == 'metric' ? '°' : '°';
    final displayForecast = forecast.skip(1).take(6).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF142038) : Colors.white;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            '7-DAY FORECAST',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayForecast.length,
            separatorBuilder: (_, __) => Divider(
              color: dividerColor,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final day = displayForecast[index];
              return _DayRow(
                day: day,
                tempUnit: tempUnit,
                index: index,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final DailyForecastModel day;
  final String tempUnit;
  final int index;
  final bool isDark;

  const _DayRow({
    required this.day,
    required this.tempUnit,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dayTextColor = isDark ? Colors.white70 : Colors.black87;
    final minTempColor = isDark ? Colors.white38 : Colors.black38;
    final maxTempColor = isDark ? Colors.white : Colors.black87;
    final rainColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              WeatherUtils.formatShortDay(day.date),
              style: TextStyle(
                color: dayTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            WeatherUtils.codeToEmoji(day.weatherCode, isDay: true),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          if (day.precipitationProbability > 0) ...[
            Icon(Icons.water_drop, size: 12, color: rainColor),
            const SizedBox(width: 2),
            Text(
              '${day.precipitationProbability.round()}%',
              style: TextStyle(color: rainColor, fontSize: 12),
            ),
          ],
          const Spacer(),
          Text(
            '${day.tempMin.round()}$tempUnit',
            style: TextStyle(
              color: minTempColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _TempBar(
            min: day.tempMin,
            max: day.tempMax,
            globalMin: 10,
            globalMax: 40,
          ),
          const SizedBox(width: 8),
          Text(
            '${day.tempMax.round()}$tempUnit',
            style: TextStyle(
              color: maxTempColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class _TempBar extends StatelessWidget {
  final double min, max, globalMin, globalMax;

  const _TempBar({
    required this.min,
    required this.max,
    required this.globalMin,
    required this.globalMax,
  });

  @override
  Widget build(BuildContext context) {
    final range = globalMax - globalMin;
    final endFrac = ((max - globalMin) / range).clamp(0.0, 1.0);

    return SizedBox(
      width: 60,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Container(color: Colors.black12),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: endFrac,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFFFF8A65)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}