import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skycast/core/network/api_client.dart';
import 'package:skycast/data/datasources/weather_remote_datasource.dart';
import 'package:skycast/data/models/weather_model.dart';
import 'package:skycast/data/repositories/weather_repository_impl.dart';
import 'package:skycast/core/errors/result.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final weatherRemoteDataSourceProvider =
    Provider<WeatherRemoteDataSource>((ref) {
  return WeatherRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepositoryImpl>((ref) {
  return WeatherRepositoryImpl(ref.read(weatherRemoteDataSourceProvider));
});

// ─── State ────────────────────────────────────────────────────────────────────

enum WeatherStatus { initial, loading, success, failure }

class WeatherState {
  final WeatherStatus status;
  final WeatherResponseModel? data;
  final String? errorMessage;
  final String? locationLabel;
  final String units;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.data,
    this.errorMessage,
    this.locationLabel,
    this.units = 'metric',
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherResponseModel? data,
    String? errorMessage,
    String? locationLabel,
    String? units,
  }) {
    return WeatherState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      locationLabel: locationLabel ?? this.locationLabel,
      units: units ?? this.units,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepositoryImpl _repo;

  WeatherNotifier(this._repo) : super(const WeatherState());

  Future<void> loadByLocation() async {
    state = state.copyWith(status: WeatherStatus.loading, errorMessage: null);

    final result = await _repo.getWeatherByLocation();

    result.when(
      success: (data) {
        state = state.copyWith(
          status: WeatherStatus.success,
          data: data,
          locationLabel: data.locationName ??
              _coordLabel(data.latitude, data.longitude),
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: WeatherStatus.failure,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadByCity(String city) async {
    state = state.copyWith(status: WeatherStatus.loading, errorMessage: null);

    final result = await _repo.getWeatherByCity(city);

    result.when(
      success: (data) {
        state = state.copyWith(
          status: WeatherStatus.success,
          data: data,
          locationLabel: data.locationName ?? city,
        );
      },
      failure: (error) {
        state = state.copyWith(
          status: WeatherStatus.failure,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> refresh() async {
    if (state.locationLabel != null) {
      await loadByCity(state.locationLabel!);
    } else {
      await loadByLocation();
    }
  }

  void toggleUnits() {
    final newUnits = state.units == 'metric' ? 'imperial' : 'metric';
    state = state.copyWith(units: newUnits);
    if (state.data != null) {
      _reloadWithUnits(newUnits);
    }
  }

  Future<void> _reloadWithUnits(String units) async {
    if (state.data == null) return;
    final data = state.data!;
    final result = await _repo.getWeatherByCoords(
      lat: data.latitude,
      lon: data.longitude,
      units: units,
    );
    result.when(
      success: (d) => state = state.copyWith(
        data: d,
        locationLabel: state.locationLabel,
      ),
      failure: (_) {},
    );
  }

  String _coordLabel(double lat, double lon) {
    final latStr = '${lat.toStringAsFixed(2)}°${lat >= 0 ? 'N' : 'S'}';
    final lonStr = '${lon.abs().toStringAsFixed(2)}°${lon >= 0 ? 'E' : 'W'}';
    return '$latStr, $lonStr';
  }
}

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref.read(weatherRepositoryProvider));
});

// Recent searches
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);