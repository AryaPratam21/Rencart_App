class Booking {
  final String? id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final String? ownerNotes;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String paymentMethod; // Always 'cash' for MVP

  Booking({
    this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.ownerNotes,
    this.location,
    this.latitude,
    this.longitude,
    this.paymentMethod = 'cash', // Default to cash
  }) : assert(userId.isNotEmpty, 'userId cannot be empty'),
       assert(vehicleId.isNotEmpty, 'vehicleId cannot be empty'),
       assert(customerName.isNotEmpty, 'customerName cannot be empty'),
       assert(customerPhone.isNotEmpty, 'customerPhone cannot be empty'),
       assert(customerEmail.isNotEmpty, 'customerEmail cannot be empty'),
       assert(totalPrice >= 0, 'totalPrice must be non-negative'),
       assert(status.isNotEmpty, 'status cannot be empty'),
       assert(paymentMethod == 'cash', 'Payment method must be cash');

  factory Booking.fromJson(Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      userId: map['userId'] as String,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      customerEmail: map['customerEmail'] as String,
      vehicleId: map['vehicleId'] as String,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: map['status'] as String,
      ownerNotes: map['ownerNotes'] as String?,
      location: map['location'] as String?,
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'vehicleId': vehicleId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'ownerNotes': ownerNotes ?? '',
      'location': location ?? '',
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
      'paymentMethod': paymentMethod,
    };
  }
}
