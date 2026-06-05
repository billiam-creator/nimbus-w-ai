import 'package:skycast/core/constants/api_constants.dart';
import 'package:skycast/core/network/api_client.dart';
import 'package:skycast/data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherResponseModel> getWeatherByCoords({
    required double lat,
    required double lon,
    String units = 'metric',
    int days = 7,
    String lang = 'en',
    bool ai = false,
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
    String lang = 'en',
    bool ai = false,
  }) async {
    final json = await _client.get(
      ApiConstants.weatherEndpoint,
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'days': days,
        'units': units,
        'lang': lang,
        'ai': ai,
      },
    );
    return WeatherResponseModel.fromJson(json, null);
  }
}