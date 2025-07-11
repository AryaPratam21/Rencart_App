import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

class BookingService {
  // ...
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: bookingId,
      );
      _ref.invalidate(ownerBookingsProvider);
      _ref.invalidate(customerBookingsProvider);
      _ref.invalidate(bookingDetailProvider(bookingId));
    } catch (e) {
      throw Exception('Gagal menghapus pesanan: $e');
    }
  }

  Future<Booking> getBookingById(String bookingId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: bookingId,
      );
      return Booking.fromJson(response.data, response.$id);
    } catch (e) {
      throw Exception('Gagal mengambil detail pesanan: $e');
    }
  }

  final Databases _databases;
  final Ref _ref;

  BookingService(this._databases, this._ref);

  Future<String> createBooking(Booking bookingData, WidgetRef ref) async {
    try {
      // 1. Dapatkan status otentikasi pengguna
      final authState = ref.read(authControllerProvider);
      if (authState.user == null) {
        throw Exception('User tidak terotentikasi');
      }

      // 2. Validasi data booking
      if (bookingData.userId.isEmpty) throw Exception('ID user tidak valid');
      if (bookingData.vehicleId.isEmpty)
        throw Exception('ID vehicle tidak valid');
      if (bookingData.startDate.isAfter(bookingData.endDate))
        throw Exception(
          'Tanggal mulai tidak boleh lebih besar dari tanggal selesai',
        );

      // 3. Dapatkan detail kendaraan
      final vehicleService = ref.read(vehicle_providers.vehicleServiceProvider);
      final vehicles = await vehicleService.getVehicles();
      final vehicle = vehicles.firstWhere(
        (v) => v.id == bookingData.vehicleId,
        orElse: () => throw Exception('Kendaraan tidak ditemukan'),
      );

      // 4. Periksa status kendaraan
      if (vehicle.status != 'tersedia') {
        throw Exception('Kendaraan sudah tidak tersedia');
      }

      // 5. Buat booking di Appwrite
      final response = await _databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': bookingData.userId,
          'vehicleId': bookingData.vehicleId,
          'startDate': bookingData.startDate.toIso8601String(),
          'endDate': bookingData.endDate.toIso8601String(),
          'status': 'pending',
          'totalPrice': bookingData.totalPrice,
        },
        permissions: [
          Permission.read(Role.users()),
          Permission.update(Role.user(bookingData.userId)),
          Permission.delete(Role.user(bookingData.userId)),
        ],
      );

      // 6. Update status kendaraan ke "Not Available"
      await vehicleService.updateVehicleStatus(
        bookingData.vehicleId,
        'Not Available',
      );

      // 7. Refresh data
      _ref.invalidate(ownerBookingsProvider);
      _ref.invalidate(customerBookingsProvider);

      return response.$id;
    } catch (e) {
      // 8. Jika gagal, rollback status kendaraan
      try {
        final vehicleService = ref.read(
          vehicle_providers.vehicleServiceProvider,
        );
        await vehicleService.updateVehicleStatus(
          bookingData.vehicleId,
          'tersedia',
        );
      } catch (_) {
        // Abaikan error rollback
      }
      throw Exception('Gagal membuat booking: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      // 1. Dapatkan dokumen booking untuk menemukan vehicleId
      final bookingDoc = await _databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: bookingId,
      );
      final vehicleId = bookingDoc.data['vehicleId'] as String?;

      if (vehicleId == null || vehicleId.isEmpty) {
        throw Exception("Vehicle ID not found or is empty in the booking.");
      }

      // 2. Perbarui status booking
      await _databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: bookingId,
        data: {'status': newStatus},
      );

      // 3. Perbarui status kendaraan yang sesuai
      final vehicleService = _ref.read(
        vehicle_providers.vehicleServiceProvider,
      );
      // Jika status baru 'onRent', status kendaraan juga 'onRent'.
      // Jika 'completed' atau status lain, kendaraan kembali 'available'.
      final String vehicleStatus = (newStatus == 'onRent')
          ? 'on_rent'
          : 'available';

      // Update status kendaraan
      await vehicleService.updateVehicleStatus(vehicleId, vehicleStatus);

      // 4. Batalkan semua provider yang relevan untuk menyegarkan UI
      _ref.invalidate(ownerBookingsProvider);
      _ref.invalidate(customerBookingsProvider);
      _ref.invalidate(bookingDetailProvider(bookingId));
      _ref.invalidate(vehicle_providers.availableVehiclesProvider);
    } catch (e) {
      debugPrint('[updateBookingStatus] Error: $e');
      throw Exception('Gagal memperbarui status pesanan: $e');
    }
  }

  Future<void> updateOwnerNotes(String bookingId, String notes) async {
    try {
      await _databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.bookingsCollectionId,
        documentId: bookingId,
        data: {'ownerNotes': notes},
      );
      _ref.invalidate(bookingDetailProvider(bookingId));
    } catch (e) {
      debugPrint('[updateOwnerNotes] Error: $e');
      throw Exception('Gagal memperbarui catatan owner: $e');
    }
  }
}

// Provider untuk state loading booking
final bookingLoadingProvider = StateProvider<bool>((ref) => false);

// Provider untuk BookingService
final bookingServiceProvider = Provider<BookingService>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  return BookingService(databases, ref);
});

// Provider untuk OWNER: Semua booking
final ownerBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  // 1. Dapatkan status otentikasi pengguna
  final user = await ref.read(authControllerProvider.notifier).getCurrentUser();

  // 2. Jika tidak ada pengguna, kembalikan list kosong
  if (user == null) {
    print(
      '[ownerBookingsProvider] Pengguna tidak login. Mengembalikan data kosong.',
    );
    return [];
  }

  // 3. Periksa apakah pengguna adalah anggota tim 'owner'
  final teamsService = ref.watch(appwriteTeamsProvider);
  try {
    final userTeams = await teamsService.list();

    final isOwner = userTeams.teams.any(
      (team) => team.$id == '6866837a003dcd8abd3d',
    );

    if (!isOwner) {
      print(
        '[ownerBookingsProvider] Pengguna bukan anggota tim owner. Mengembalikan data kosong.',
      );
      return [];
    }
  } on AppwriteException catch (e) {
    print(
      '[ownerBookingsProvider] Gagal memeriksa tim pengguna: $e. Mengembalikan data kosong.',
    );
    return [];
  }

  // 4. Hanya jika pengguna adalah owner, lanjutkan mengambil data
  final databases = ref.watch(appwriteDatabasesProvider);
  print(
    '[ownerBookingsProvider] Pengguna adalah owner. Mulai mengambil data booking...',
  );
  try {
    final result = await databases.listDocuments(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.bookingsCollectionId,
      queries: [Query.orderDesc('\$createdAt')],
    );
    print(
      '[ownerBookingsProvider] Berhasil! Ditemukan ${result.total} dokumen.',
    );
    if (result.documents.isNotEmpty) {
      print(
        '[ownerBookingsProvider] Contoh data dokumen pertama: ${result.documents.first.data}',
      );
    }
    return result.documents
        .map((doc) => Booking.fromJson(doc.data, doc.$id))
        .toList();
  } catch (e) {
    print('[ownerBookingsProvider] TERJADI ERROR: $e');
    rethrow; // Tetap lempar error agar UI bisa menampilkannya
  }
});

// Provider untuk CUSTOMER: Booking milik user saat ini
final customerBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final user = await ref.read(authControllerProvider.notifier).getCurrentUser();
  if (user == null) {
    debugPrint(
      '[customerBookingsProvider] Pengguna tidak login. Return empty.',
    );
    return [];
  }
  final databases = ref.watch(appwriteDatabasesProvider);
  final result = await databases.listDocuments(
    databaseId: AppConstants.appwriteDatabaseId,
    collectionId: AppConstants.bookingsCollectionId,
    queries: [Query.equal('userId', user.$id), Query.orderDesc('\$createdAt')],
  );
  debugPrint(
    '[customerBookingsProvider] User: ${user.$id}, Ditemukan booking: ${result.total}',
  );
  return result.documents
      .map((doc) => Booking.fromJson(doc.data, doc.$id))
      .toList();
});

// Provider untuk DETAIL SATU BOOKING
final bookingDetailProvider = FutureProvider.autoDispose
    .family<Booking?, String>((ref, bookingId) async {
      if (bookingId.isEmpty) return null;
      final databases = ref.watch(appwriteDatabasesProvider);
      try {
        final document = await databases.getDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.bookingsCollectionId,
          documentId: bookingId,
        );
        return Booking.fromJson(document.data, document.$id);
      } on AppwriteException catch (e) {
        if (e.code == 404) return null;
        throw Exception('Failed to load booking detail: ${e.message}');
      }
    });
