import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nimbus/core/errors/exceptions.dart';

class LocationUtils {
  LocationUtils._();

  /// Get device GPS coordinates
  static Future<({double lat, double lon})> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Location permission permanently denied. Enable it in settings.');
    }

   final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.low,
  timeLimit: const Duration(seconds: 10),
);
    return (lat: position.latitude, lon: position.longitude);
  }

  /// Convert city name to lat/lon
  static Future<({double lat, double lon, String city})> cityToCoords(
      String cityName) async {
    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isEmpty) {
        throw const LocationException('City not found. Try a different name.');
      }
      final first = locations.first;
      final placemarks =
          await placemarkFromCoordinates(first.latitude, first.longitude);
      final city = placemarks.isNotEmpty
          ? (placemarks.first.locality ??
              placemarks.first.administrativeArea ??
              cityName)
          : cityName;
      return (lat: first.latitude, lon: first.longitude, city: city);
    } on LocationException {
      rethrow;
    } catch (_) {
      throw const LocationException('City not found. Try a different name.');
    }
  }
}
