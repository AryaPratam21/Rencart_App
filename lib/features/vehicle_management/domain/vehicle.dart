class Vehicle {
  final String? id;
  final String name;
  final String plateNumber;
  final double rentalPricePerDay;
  String status; // Ubah jadi non-final agar bisa diupdate statusnya di UI
  final List<String> imageUrls;
  final String? transmission;
  final int? capacity;
  final String? description;
  final String currentLocationCity;
  final String? vin; // Tambahkan VIN
  final int? mileage; // Tambahkan Mileage
  final int? year;

  Vehicle({
    this.id,
    required this.name,
    required this.plateNumber,
    required this.rentalPricePerDay,
    required this.status,
    required this.imageUrls,
    this.transmission,
    this.capacity,
    this.description,
    required this.currentLocationCity,
    this.vin,
    this.mileage,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'plateNumber': plateNumber,
      'rentalPricePerDay': rentalPricePerDay,
      'status': status,
      'imageUrls': imageUrls,
      'transmission': transmission,
      'capacity': capacity,
      'description': description,
      'currentLocationCity': currentLocationCity,
      'vin': vin,
      'mileage': mileage,
      'year': year,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> map, String documentId) {
    return Vehicle(
      id: documentId,
      name: map['name'] as String,
      plateNumber: map['plateNumber'] as String,
      rentalPricePerDay: (map['rentalPricePerDay'] as num).toDouble(),
      status: map['status'] as String,
      imageUrls: List<String>.from(map['imageUrls'] as List? ?? []),
      transmission: map['transmission'] as String?,
      capacity: map['capacity'] as int?,
      description: map['description'] as String?,
      currentLocationCity: map['currentLocationCity'] as String,
      vin: map['vin'] as String?,
      mileage: map['mileage'] as int?,
    );
  }

  Vehicle copyWith({
    String? id,
    String? name,
    String? plateNumber,
    double? rentalPricePerDay,
    String? status,
    List<String>? imageUrls,
    String? transmission,
    int? capacity,
    String? description,
    String? currentLocationCity,
    String? vin,
    int? mileage,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      plateNumber: plateNumber ?? this.plateNumber,
      rentalPricePerDay: rentalPricePerDay ?? this.rentalPricePerDay,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      transmission: transmission ?? this.transmission,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      currentLocationCity: currentLocationCity ?? this.currentLocationCity,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
    );
  }
}
