import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/gym_location_model.dart';
import '../core/services/firebase_service.dart';
import '../core/services/location_service.dart';

class LocationsProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final FirebaseService _firebaseService = FirebaseService();

  List<GymLocationModel> _locations = GymLocationModel.getSampleLocations();
  List<GymLocationModel> get locations => _locations;

  GymLocationModel? _selectedLocation;
  GymLocationModel? get selectedLocation =>
      _selectedLocation ?? (_locations.isNotEmpty ? _locations.first : null);

  LatLng _currentCenter = const LatLng(19.4290, -99.1623);
  LatLng get currentCenter => _currentCenter;

  bool _isLoadingGps = false;
  bool get isLoadingGps => _isLoadingGps;

  bool _isLoadingLocations = false;
  bool get isLoadingLocations => _isLoadingLocations;

  String? _userGpsStatus;
  String? get userGpsStatus => _userGpsStatus;

  StreamSubscription<List<GymLocationModel>>? _locationsSubscription;

  LocationsProvider() {
    _initLocationsStream();
    refreshUserLocation();
  }

  void _initLocationsStream() {
    if (_firebaseService.hasRealCredentials) {
      _isLoadingLocations = true;
      notifyListeners();

      _locationsSubscription = _firebaseService.streamGymLocations().listen(
        (firestoreLocations) {
          if (firestoreLocations.isNotEmpty) {
            _locations = firestoreLocations;
          }
          // Si Firestore devuelve vacío, mantener las ubicaciones de muestra
          _isLoadingLocations = false;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('[LocationsProvider] Error streaming locations: $e');
          _isLoadingLocations = false;
          notifyListeners();
        },
      );
    }
  }

  void selectLocation(GymLocationModel location) {
    _selectedLocation = location;
    _currentCenter = LatLng(location.latitude, location.longitude);
    notifyListeners();
  }

  Future<void> refreshUserLocation() async {
    _isLoadingGps = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _locations = _locationService.sortLocationsByProximity(
          _locations,
          position.latitude,
          position.longitude,
        );
        _userGpsStatus =
            'GPS Activo: ${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}';
      } else {
        _userGpsStatus = 'Ubicación predeterminada (Sede Central)';
      }
    } catch (e) {
      _userGpsStatus = 'No se pudo obtener GPS en este dispositivo';
    }

    _isLoadingGps = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationsSubscription?.cancel();
    super.dispose();
  }
}
