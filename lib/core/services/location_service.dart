import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/gym_location_model.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] El servicio de ubicación GPS está desactivado.');
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Permiso de ubicación denegado.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Permiso denegado permanentemente.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      debugPrint('[LocationService] Error obteniendo posición: $e');
      return null;
    }
  }

  /// Calcula la distancia en kilómetros entre el usuario y una sede
  double calculateDistanceKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final double distanceMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceMeters / 1000.0;
  }

  /// Ordena las sedes según la cercanía al usuario
  List<GymLocationModel> sortLocationsByProximity(
    List<GymLocationModel> locations,
    double userLat,
    double userLng,
  ) {
    final updated = locations.map((loc) {
      final dist = calculateDistanceKm(userLat, userLng, loc.latitude, loc.longitude);
      return loc.copyWith(distanceKm: double.parse(dist.toStringAsFixed(1)));
    }).toList();

    updated.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return updated;
  }
}
