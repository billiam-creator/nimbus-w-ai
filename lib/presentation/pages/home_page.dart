import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skycast/presentation/providers/weather_provider.dart';
import 'package:skycast/presentation/widgets/ai_summary_card.dart';
import 'package:skycast/presentation/widgets/current_weather_card.dart';
import 'package:skycast/presentation/widgets/daily_forecast_section.dart';
import 'package:skycast/presentation/widgets/hourly_forecast_section.dart';
import 'package:skycast/presentation/widgets/loading_skeleton.dart';
import 'package:skycast/presentation/widgets/search_bar_widget.dart'
    as search;

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

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar always visible
            const search.SearchBar(),

            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WeatherState state) {
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
          backgroundColor: const Color(0xFF142038),
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
                if (weather.aiSummary != null && weather.aiSummary!.isNotEmpty)
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
              style: const TextStyle(color: Colors.white70, fontSize: 16),
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
  final VoidCallback onToggleUnits;

  const _Footer({required this.units, required this.onToggleUnits});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Units toggle
          GestureDetector(
            onTap: onToggleUnits,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF142038),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _UnitLabel('°C', units == 'metric'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('/', style: TextStyle(color: Colors.white38)),
                  ),
                  _UnitLabel('°F', units == 'imperial'),
                ],
              ),
            ),
          ),
          // Attribution
          const Text(
            'Powered by WeatherAI',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  final String text;
  final bool active;

  const _UnitLabel(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: active ? Colors.white : Colors.white38,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        fontSize: 14,
      ),
    );
  }
}
