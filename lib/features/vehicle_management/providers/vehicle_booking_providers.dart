import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';

// Gunakan availableVehiclesProvider dari vehicle_providers.dart
// Tidak perlu didefinisikan ulang jika sudah ada di sana

final vehicleBookingsProvider = FutureProvider.family<List<Booking>, String>((ref, vehicleId) async {
  final client = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e');
  final database = appwrite.Databases(client);

  final response = await database.listDocuments(
    databaseId: '68356389002850d27576', // Ganti dengan databaseId Anda
    collectionId: '683566ce00237874d560', // Ganti dengan collectionId bookings
    queries: [
      appwrite.Query.equal('vehicleId', vehicleId),
      appwrite.Query.equal('status', 'completed'),
    ],
  );

  return response.documents.map((doc) => Booking.fromJson(doc.data, doc.$id)).toList();
});
