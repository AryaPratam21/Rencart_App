import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';

// Provider untuk client Appwrite (bisa sesuaikan dengan project Anda)
final appwriteClientProvider = Provider<appwrite.Client>((ref) {
  return appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e'); // Ganti dengan project ID Anda
});

// Provider untuk detail booking dari database Appwrite
final bookingDetailProvider =
    FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final client = ref.read(appwriteClientProvider);
  final database = appwrite.Databases(client);

  try {
    final doc = await database.getDocument(
      databaseId: '68350fb100246925095e', // Ganti dengan database ID Anda
      collectionId:
          '683566ce00237874d560', // Ganti dengan collection ID booking Anda
      documentId: bookingId,
    );

    return Booking(
      id: doc.$id,
      customerName: doc.data['customerName'] ?? '',
      customerPhone: doc.data['customerPhone'] ?? '',
      customerEmail: doc.data['customerEmail'] ?? '',
      vehicleId: doc.data['vehicleId'] ?? '',
      startDate: DateTime.parse(doc.data['startDate']),
      endDate: DateTime.parse(doc.data['endDate']),
      totalPrice: doc.data['totalPrice'] is int
          ? (doc.data['totalPrice'] as int).toDouble()
          : (doc.data['totalPrice'] ?? 0.0),
      status: doc.data['status'] ?? '',
      ownerNotes: doc.data['ownerNotes'] ?? '',
    );
  } catch (e) {
    // Jika booking tidak ditemukan atau error, kembalikan null
    return null;
  }
});
