import 'package:nimbus/core/constants/api_constants.dart';
import 'package:nimbus/core/network/api_client.dart';
import 'package:nimbus/data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherResponseModel> getWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
    int days = 7,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient _client;

  WeatherRemoteDataSourceImpl(this._client);

  @override
  Future<WeatherResponseModel> getWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
    int days = 7,
  }) async {
    final rawJson = await _client.get(
      ApiConstants.weatherEndpoint,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'days': days,
        'units': units,
      },
    );
    return WeatherResponseModel.fromJson(rawJson, null);
  }
}