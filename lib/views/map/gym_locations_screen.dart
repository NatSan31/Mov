import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/locations_provider.dart';

class GymLocationsScreen extends StatelessWidget {
  const GymLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationsProvider = context.watch<LocationsProvider>();
    final selected = locationsProvider.selectedLocation;
    final userPos = locationsProvider.userLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedes & Navegación GPS'),
        actions: [
          IconButton(
            icon: locationsProvider.isLoadingGps
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Centrar en mi ubicación GPS',
            onPressed: () => locationsProvider.refreshUserLocation(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. MAPA NATIVO CON CAPAS (TileLayer, PolylineLayer de ruta y MarkerLayer)
          FlutterMap(
            options: MapOptions(
              initialCenter: locationsProvider.currentCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fitpulse.fitpulse_app',
              ),

              // Capa de Ruta más Rápida (PolylineLayer)
              if (locationsProvider.isRouteActive && locationsProvider.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: locationsProvider.routePoints,
                      strokeWidth: 5.0,
                      color: AppColors.secondary,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.black54,
                    ),
                  ],
                ),

              // Capa de Marcadores (Ubicación del usuario + Sedes)
              MarkerLayer(
                markers: [
                  // Marcador de Ubicación del Atleta (Usuario)
                  if (userPos != null)
                    Marker(
                      point: userPos,
                      width: 50,
                      height: 50,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),

                  // Marcadores de Sedes de FitPulse
                  ...locationsProvider.locations.map((loc) {
                    final isCurrentSelected = selected?.id == loc.id;
                    return Marker(
                      point: LatLng(loc.latitude, loc.longitude),
                      width: isCurrentSelected ? 52 : 42,
                      height: isCurrentSelected ? 52 : 42,
                      child: GestureDetector(
                        onTap: () => locationsProvider.selectLocation(loc),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentSelected ? AppColors.primary : AppColors.darkSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentSelected ? Colors.white : AppColors.primary,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: isCurrentSelected ? Colors.white : AppColors.primaryLight,
                            size: isCurrentSelected ? 26 : 20,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Banner de estado superior con modo GPS
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationsProvider.userGpsStatus ?? 'GPS Activo',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                  if (locationsProvider.isRouteActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Ruta Activa',
                        style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Ficha inferior interactiva con Información de Ruta y Sede
          if (selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y distancia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selected.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'A ${selected.distanceKm} km',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            selected.address,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Estimaciones de Ruta más Rápida (si está activa)
                    if (locationsProvider.isRouteActive) ...[
                      const Divider(height: 16, color: Colors.white12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.directions_car, color: AppColors.secondary, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Auto: ${locationsProvider.estimatedCarTime}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Container(width: 1, height: 20, color: Colors.white24),
                                Row(
                                  children: [
                                    const Icon(Icons.directions_walk, color: Colors.orangeAccent, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'A pie: ${locationsProvider.estimatedWalkTime}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                locationsProvider.routeAvenueName,
                                style: const TextStyle(fontSize: 11, color: Colors.white70, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Botón para trazar / ocultar ruta
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: locationsProvider.isRouteActive ? Colors.grey.shade800 : AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(
                              locationsProvider.isRouteActive ? Icons.cancel_outlined : Icons.directions,
                              size: 18,
                            ),
                            label: Text(
                              locationsProvider.isRouteActive ? 'OCULTAR RUTA' : 'TRAZAR RUTA MÁS RÁPIDA',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (locationsProvider.isRouteActive) {
                                locationsProvider.clearRoute();
                              } else {
                                locationsProvider.calculateFastestRoute();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
