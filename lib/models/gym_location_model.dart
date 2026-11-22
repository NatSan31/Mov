class GymLocationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String schedule;
  final List<String> amenities;
  final double distanceKm;

  GymLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.schedule,
    required this.amenities,
    this.distanceKm = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'schedule': schedule,
      'amenities': amenities,
    };
  }

  factory GymLocationModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return GymLocationModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      phone: map['phone'] ?? '',
      schedule: map['schedule'] ?? '24/7',
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }

  GymLocationModel copyWith({double? distanceKm}) {
    return GymLocationModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      schedule: schedule,
      amenities: amenities,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  static List<GymLocationModel> getSampleLocations() {
    return [
      GymLocationModel(
        id: 'loc_1',
        name: 'FitPulse Central Flagship Club',
        address: 'Av. Paseo de la Reforma 222, Cuauhtémoc, CDMX',
        latitude: 19.4290,
        longitude: -99.1623,
        phone: '+52 55 1234 5678',
        schedule: 'Abierto 24 Horas',
        amenities: ['Piscina Olímpica', 'CrossFit Box', 'Sauna & Spa', 'Zona VIP Black', 'Pro Shop'],
        distanceKm: 1.2,
      ),
      GymLocationModel(
        id: 'loc_2',
        name: 'FitPulse Polanco Elite Studio',
        address: 'Campos Elíseos 204, Polanco, Miguel Hidalgo, CDMX',
        latitude: 19.4285,
        longitude: -99.1915,
        phone: '+52 55 8765 4321',
        schedule: 'Lun - Dom: 05:00 - 23:00',
        amenities: ['Recovery Lounge', 'Pilates Reformer', 'Cycling Stadium', 'Nutrición In-House'],
        distanceKm: 3.5,
      ),
      GymLocationModel(
        id: 'loc_3',
        name: 'FitPulse Santa Fe High Performance',
        address: 'Vasco de Quiroga 3800, Santa Fe, Cuajimalpa, CDMX',
        latitude: 19.3592,
        longitude: -99.2588,
        phone: '+52 55 9988 7766',
        schedule: 'Abierto 24 Horas',
        amenities: ['Canchas de Pádel', 'Pista de Atletismo Indoor', 'Cryoterapia', 'Cafetería Fit'],
        distanceKm: 8.7,
      ),
    ];
  }
}
