import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbus/presentation/providers/weather_provider.dart';
import 'package:nimbus/presentation/widgets/ai_summary_card.dart';
import 'package:nimbus/presentation/widgets/current_weather_card.dart';
import 'package:nimbus/presentation/widgets/daily_forecast_section.dart';
import 'package:nimbus/presentation/widgets/hourly_forecast_section.dart';
import 'package:nimbus/presentation/widgets/loading_skeleton.dart';
import 'package:nimbus/presentation/widgets/search_bar_widget.dart' as search;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).loadByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with clean separation
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const search.SearchBar(),
            ),

            Expanded(
              child: _buildBody(state, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WeatherState state, bool isDark) {
    switch (state.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const WeatherLoadingSkeleton();

      case WeatherStatus.failure:
        return _ErrorView(
          message: state.errorMessage ?? 'Something went wrong.',
          onRetry: () => ref.read(weatherProvider.notifier).loadByLocation(),
        );

      case WeatherStatus.success:
        final weather = state.data!;
        return RefreshIndicator(
          color: const Color(0xFF64B5F6),
          backgroundColor:
              isDark ? const Color(0xFF142038) : Colors.white,
          onRefresh: () => ref.read(weatherProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero card
                CurrentWeatherCard(
                  weather: weather,
                  locationLabel: state.locationLabel ?? 'Your Location',
                  units: state.units,
                ),

                // AI Summary
                if (weather.aiSummary != null &&
                    weather.aiSummary!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AiSummaryCard(summary: weather.aiSummary!),
                  ),

                // Hourly
                if (weather.hourly.isNotEmpty)
                  HourlyForecastSection(
                    hourly: weather.hourly,
                    units: state.units,
                  ),

                // Daily
                if (weather.daily.isNotEmpty)
                  DailyForecastSection(
                    forecast: weather.daily,
                    units: state.units,
                  ),

                // Units toggle + attribution
                _Footer(
                  units: state.units,
                  isDark: isDark,
                  onToggleUnits: () =>
                      ref.read(weatherProvider.notifier).toggleUnits(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⛈️', style: TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4D8C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String units;
  final bool isDark;
  final VoidCallback onToggleUnits;

  const _Footer({
    required this.units,
    required this.isDark,
    required this.onToggleUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onToggleUnits,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF142038)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Row(
                children: [
                  _UnitLabel('°C', units == 'metric', isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '/',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ),
                  ),
                  _UnitLabel('°F', units == 'imperial', isDark),
                ],
              ),
            ),
          ),
          Text(
            'Powered by WeatherAI',
            style: TextStyle(
              color: isDark ? Colors.white24 : Colors.black26,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  final String text;
  final bool active;
  final bool isDark;

  const _UnitLabel(this.text, this.active, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: active
            ? (isDark ? Colors.white : Colors.black87)
            : (isDark ? Colors.white38 : Colors.black38),
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        fontSize: 14,
      ),
    );
  }
}