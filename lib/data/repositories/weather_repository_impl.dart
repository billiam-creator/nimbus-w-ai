import 'package:skycast/core/errors/exceptions.dart';
import 'package:skycast/core/errors/result.dart';
import 'package:skycast/core/utils/location_utils.dart';
import 'package:skycast/data/datasources/weather_remote_datasource.dart';
import 'package:skycast/data/models/weather_model.dart';

abstract class WeatherRepository {
  Future<Result<WeatherResponseModel>> getWeatherByCoords({
    required double lat,
    required double lon,
    String units,
    int days,
  });

  Future<Result<WeatherResponseModel>> getWeatherByCity(String cityName);
  Future<Result<WeatherResponseModel>> getWeatherByLocation();
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remote;

  WeatherRepositoryImpl(this._remote);

  @override
  Future<Result<WeatherResponseModel>> getWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
    int days = 7,
  }) async {
    try {
      final result = await _remote.getWeatherByCoords(
        lat: lat,
        lon: lon,
        units: units,
        days: days,
        ai: false,
      );
      return Success(result);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ServerException(e.toString()));
    }
  }

  @override
  Future<Result<WeatherResponseModel>> getWeatherByCity(String cityName) async {
    try {
      final coords = await LocationUtils.cityToCoords(cityName);
      final json = await _remote.getWeatherByCoords(
        lat: coords.lat,
        lon: coords.lon,
        ai: false,
      );
      final enriched = WeatherResponseModel(
        current: json.current,
        daily: json.daily,
        hourly: json.hourly,
        aiSummary: json.aiSummary,
        latitude: json.latitude,
        longitude: json.longitude,
        timezone: json.timezone,
        locationName: coords.city,
      );
      return Success(enriched);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ServerException(e.toString()));
    }
  }

  @override
  Future<Result<WeatherResponseModel>> getWeatherByLocation() async {
    try {
      final coords = await LocationUtils.getCurrentPosition();
      return getWeatherByCoords(lat: coords.lat, lon: coords.lon);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(LocationException(e.toString()));
    }
  }
}