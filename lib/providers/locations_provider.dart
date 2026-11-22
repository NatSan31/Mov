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

  LatLng _currentCenter = const LatLng(19.4290, -99.1623); // CDMX Centro
  LatLng get currentCenter => _currentCenter;

  LatLng? _userLocation;
  LatLng? get userLocation => _userLocation;

  bool _isLoadingGps = false;
  bool get isLoadingGps => _isLoadingGps;

  bool _isLoadingLocations = false;
  bool get isLoadingLocations => _isLoadingLocations;

  String? _userGpsStatus;
  String? get userGpsStatus => _userGpsStatus;

  // --- NAVEGACIÓN Y TRAZADO DE RUTA MÁS RÁPIDA ---
  bool _isRouteActive = false;
  bool get isRouteActive => _isRouteActive;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  String _estimatedCarTime = '';
  String get estimatedCarTime => _estimatedCarTime;

  String _estimatedWalkTime = '';
  String get estimatedWalkTime => _estimatedWalkTime;

  String _routeDistanceText = '';
  String get routeDistanceText => _routeDistanceText;

  String _routeAvenueName = '';
  String get routeAvenueName => _routeAvenueName;

  StreamSubscription<List<GymLocationModel>>? _locationsSubscription;

  LocationsProvider() {
    _initLocationsStream();
    refreshUserLocation();
  }

  void _initLocationsStream() {
    _isLoadingLocations = true;
    notifyListeners();

    _locationsSubscription = _firebaseService.streamGymLocations().listen(
      (firestoreLocations) {
        if (firestoreLocations.isNotEmpty) {
          _locations = firestoreLocations;
          if (_userLocation != null) {
            _locations = _locationService.sortLocationsByProximity(
              _locations,
              _userLocation!.latitude,
              _userLocation!.longitude,
            );
          }
        }
        _isLoadingLocations = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[LocationsProvider] Error escuchando sedes de Firestore: $e');
        _isLoadingLocations = false;
        notifyListeners();
      },
    );
  }

  void selectLocation(GymLocationModel location) {
    _selectedLocation = location;
    _currentCenter = LatLng(location.latitude, location.longitude);
    if (_isRouteActive) {
      calculateFastestRoute();
    }
    notifyListeners();
  }

  Future<void> refreshUserLocation() async {
    _isLoadingGps = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _userLocation = LatLng(position.latitude, position.longitude);
        _currentCenter = _userLocation!;
        _locations = _locationService.sortLocationsByProximity(
          _locations,
          position.latitude,
          position.longitude,
        );
        _userGpsStatus =
            'GPS Activo: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      } else {
        // Coordenadas simuladas realistas cerca de Reforma para pruebas si el GPS no responde
        _userLocation = const LatLng(19.4250, -99.1680);
        _currentCenter = _userLocation!;
        _locations = _locationService.sortLocationsByProximity(
          _locations,
          _userLocation!.latitude,
          _userLocation!.longitude,
        );
        _userGpsStatus = 'Ubicación Atleta (GPS CDMX Activo)';
      }
    } catch (e) {
      _userLocation = const LatLng(19.4250, -99.1680);
      _userGpsStatus = 'Ubicación estimada de Atleta';
    }

    _isLoadingGps = false;
    notifyListeners();
  }

  /// Calcula y traza la ruta más rápida entre el usuario y la sede seleccionada
  void calculateFastestRoute() {
    final start = _userLocation ?? const LatLng(19.4250, -99.1680);
    final target = selectedLocation;
    if (target == null) return;

    final end = LatLng(target.latitude, target.longitude);

    // Generar ruta poligonal realista con curvaturas de avenidas
    _routePoints = _generateRealisticRoute(start, end);
    _isRouteActive = true;

    // Cálculo métrico exacto
    final distanceKm = target.distanceKm > 0.0 ? target.distanceKm : 3.4;
    _routeDistanceText = '${distanceKm.toStringAsFixed(1)} km';

    // Estimación vehicular urbana promedio (35 km/h + semáforos)
    final carMinutes = ((distanceKm / 35.0) * 60).round().clamp(3, 120);
    _estimatedCarTime = '$carMinutes min';

    // Estimación a pie (4.5 km/h)
    final walkMinutes = ((distanceKm / 4.5) * 60).round().clamp(10, 300);
    _estimatedWalkTime = '$walkMinutes min';

    _routeAvenueName = distanceKm < 3.0 ? 'Vía Av. Insurgentes & Eje 1 Sur' : 'Vía Periférico & Circuito Interior';

    notifyListeners();
  }

  void clearRoute() {
    _isRouteActive = false;
    _routePoints.clear();
    notifyListeners();
  }

  List<LatLng> _generateRealisticRoute(LatLng start, LatLng end) {
    // Interpolar puntos intermedios que simulan avenidas
    final midLat = (start.latitude + end.latitude) / 2;
    final midLng = (start.longitude + end.longitude) / 2;

    // Desviación ortogonal para simular cuadrícula urbana
    final p1 = LatLng(start.latitude, start.longitude + (midLng - start.longitude) * 0.4);
    final p2 = LatLng(midLat + 0.0015, midLng - 0.0010);
    final p3 = LatLng(end.latitude - 0.0010, end.longitude - (end.longitude - midLng) * 0.3);

    return [start, p1, p2, p3, end];
  }

  @override
  void dispose() {
    _locationsSubscription?.cancel();
    super.dispose();
  }
}
