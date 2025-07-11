// [PERBAIKAN LENGKAP] Salin dan tempel seluruh kelas ini

class Vehicle {
  final String? id;
  final String ownerId;
  final String name;
  final String status;
  final String plate_number;
  final double rentalPricePerDay;
  final List<String> image_urls;
  final String? vin;
  final int? mileage;
  final int? year;
  final String? lastBookingUserId;
  final int capacity;
  final String transmission;
  final String description;
  final String currentLocationCity;
  final String location;
  final double latitude;
  final double longitude;

  Vehicle({
    this.id,
    required this.ownerId,
    required this.name,
    required this.status,
    required this.plate_number,
    required this.rentalPricePerDay,
    required this.image_urls,
    this.vin,
    this.mileage,
    this.year,
    this.lastBookingUserId,
    required this.capacity,
    required this.transmission,
    required this.description,
    required this.currentLocationCity,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'status': status,
      'plate_number': plate_number,
      'rentalPricePerDay': rentalPricePerDay,
      'image_urls': image_urls,
      'vin': vin,
      'mileage': mileage,
      'year': year,
      'lastBookingUserId': lastBookingUserId,
      'capacity': capacity,
      'transmission': transmission,
      'description': description,
      'currentLocationCity': currentLocationCity,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['\$id'] as String? ?? map['id'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? '',
      plate_number: map['plate_number'] as String? ?? '',
      rentalPricePerDay: (map['rentalPricePerDay'] as num? ?? 0.0).toDouble(),
      image_urls: List<String>.from(map['image_urls'] as List<dynamic>? ?? []),
      vin: map['vin'] as String?,
      mileage: map['mileage'] as int?,
      year: map['year'] as int?,
      lastBookingUserId: map['lastBookingUserId'] as String?,
      capacity: map['capacity'] as int? ?? 0,
      transmission: map['transmission'] as String? ?? '',
      description: map['description'] as String? ?? '',
      currentLocationCity: map['currentLocationCity'] as String? ?? '',
      location: map['location'] as String? ?? '',
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? status,
    String? plate_number,
    double? rentalPricePerDay,
    List<String>? image_urls,
    String? vin,
    int? mileage,
    int? year,
    String? lastBookingUserId,
    int? capacity,
    String? transmission,
    String? description,
    String? currentLocationCity,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      status: status ?? this.status,
      plate_number: plate_number ?? this.plate_number,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      image_urls: image_urls ?? this.image_urls,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      year: year ?? this.year,
      lastBookingUserId: lastBookingUserId ?? this.lastBookingUserId,
      capacity: capacity ?? this.capacity,
      transmission: transmission ?? this.transmission,
      description: description ?? this.description,
      currentLocationCity: currentLocationCity ?? this.currentLocationCity,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Default constructor untuk membuat Vehicle baru
  factory Vehicle.empty() {
    return Vehicle(
      ownerId: '',
      name: '',
      status: '',
      plate_number: '',
      rentalPricePerDay: 0,
      image_urls: [],
      capacity: 0,
      transmission: '',
      description: '',
      currentLocationCity: '',
      location: '',
      latitude: 0.0,
      longitude: 0.0,
    );
  }
}
