class Booking {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final String status;
  final String ownerNotes;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.ownerNotes,
  });
}

class Vehicle {
  final String id;
  final String name;
  final String plateNumber;
  final int rentalPricePerDay;
  final String status;
  final List<String> imageUrls;
  final String currentLocationCity;

  Vehicle({
    required this.id,
    required this.name,
    required this.plateNumber,
    required this.rentalPricePerDay,
    required this.status,
    required this.imageUrls,
    required this.currentLocationCity,
  });
}
