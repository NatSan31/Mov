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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedes & Clubes FitPulse'),
        actions: [
          IconButton(
            icon: locationsProvider.isLoadingGps
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Mi ubicación GPS',
            onPressed: () => locationsProvider.refreshUserLocation(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. MAPA NATIVO INTEGRADO (No WebView, renderizado nativo con flutter_map)
          FlutterMap(
            options: MapOptions(
              initialCenter: locationsProvider.currentCenter,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fitpulse.fitpulse_app',
              ),
              MarkerLayer(
                markers: locationsProvider.locations.map((loc) {
                  final isCurrentSelected = selected?.id == loc.id;
                  return Marker(
                    point: LatLng(loc.latitude, loc.longitude),
                    width: isCurrentSelected ? 50 : 40,
                    height: isCurrentSelected ? 50 : 40,
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
                              blurRadius: 10,
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
                }).toList(),
              ),
            ],
          ),

          // 2. Banner de estado de GPS superior
          if (locationsProvider.userGpsStatus != null)
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
                    const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationsProvider.userGpsStatus!,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Ficha inferior flotante con la información de la sede seleccionada
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          selected.schedule,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: selected.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        );
                      }).toList(),
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
