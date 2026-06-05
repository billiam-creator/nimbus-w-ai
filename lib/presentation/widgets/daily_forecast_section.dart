import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skycast/core/utils/weather_utils.dart';
import 'package:skycast/data/models/weather_model.dart';

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
            color: const Color(0xFF142038),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayForecast.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.white.withOpacity(0.06),
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

  const _DayRow({
    required this.day,
    required this.tempUnit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 48,
            child: Text(
              WeatherUtils.formatShortDay(day.date),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          // Weather emoji
          Text(
            WeatherUtils.codeToEmoji(day.weatherCode),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          // Rain chance
          if (day.precipitationProbability > 0) ...[
            const Icon(Icons.water_drop, size: 12, color: Color(0xFF64B5F6)),
            const SizedBox(width: 2),
            Text(
              '${day.precipitationProbability.round()}%',
              style: const TextStyle(
                color: Color(0xFF64B5F6),
                fontSize: 12,
              ),
            ),
          ],
          const Spacer(),
          // Min/max temp
          Text(
            '${day.tempMin.round()}$tempUnit',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          // Temp bar
          _TempBar(
            min: day.tempMin,
            max: day.tempMax,
            globalMin: 10,
            globalMax: 40,
          ),
          const SizedBox(width: 8),
          Text(
            '${day.tempMax.round()}$tempUnit',
            style: const TextStyle(
              color: Colors.white,
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
    final startFrac = ((min - globalMin) / range).clamp(0.0, 1.0);
    final endFrac = ((max - globalMin) / range).clamp(0.0, 1.0);

    return SizedBox(
      width: 60,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Container(color: Colors.white12),
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
