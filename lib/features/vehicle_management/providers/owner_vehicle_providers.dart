import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/vehicle.dart';

class VehicleService {
  final appwrite.Client client;
  VehicleService(this.client);

  Future<void> addVehicle(vehicle, List<XFile> images) async {
    final storage = appwrite.Storage(client);
    final database = appwrite.Databases(client);

    // 1. Upload semua gambar ke storage
    List<String> imageUrls = [];
    for (final xfile in images) {
      appwrite.InputFile inputFile;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        inputFile = appwrite.InputFile.fromBytes(
          bytes: bytes,
          filename: xfile.name,
          contentType: xfile.mimeType ?? 'image/jpeg',
        );
      } else {
        inputFile = appwrite.InputFile.fromPath(path: xfile.path);
      }

      final result = await storage.createFile(
        bucketId:
            '683e64aa002e6a85f935', // <-- Ganti dengan bucket ID asli Anda
        fileId: appwrite.ID.unique(),
        file: inputFile,
      );
      final fileId = result.$id;
      final imageUrl =
          'https://cloud.appwrite.io/v1/storage/buckets/683e64aa002e6a85f935/files/$fileId/view?project=68350fb100246925095e&mode=admin';
      imageUrls.add(imageUrl);
    }

    // 2. Simpan data mobil ke database
    await database.createDocument(
      databaseId: '68356389002850d27576',
      collectionId: '6835644f0004a0a373f8',
      documentId: appwrite.ID.unique(),
      data: {
        'name': vehicle.name,
        'plateNumber': vehicle.plateNumber,
        'rentalPricePerDay': vehicle.rentalPricePerDay,
        'status': vehicle.status,
        'imageUrls': imageUrls,
        'transmission': vehicle.transmission,
        'capacity': vehicle.capacity,
        'description': vehicle.description,
        'currentLocationCity': vehicle.currentLocationCity,
        // ...field lain sesuai model Anda
      },
    );
  }

  Future<void> updateVehicle(
      Vehicle vehicle, List images, List<String> oldImages) async {}
}

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  final client = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e');
  return VehicleService(client);
});

// Provider untuk daftar mobil dari database Appwrite
final ownerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final client = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e');

  final database = appwrite.Databases(client);

  final response = await database.listDocuments(
    databaseId: '68356389002850d27576',
    collectionId: '6835644f0004a0a373f8',
  );

  return response.documents
      .map((doc) => Vehicle(
            id: doc.$id,
            name: doc.data['name'] ?? '',
            plateNumber: doc.data['plateNumber'] ?? '',
            rentalPricePerDay: doc.data['rentalPricePerDay'] ?? 0,
            status: doc.data['status'] ?? '',
            imageUrls: List<String>.from(doc.data['imageUrls'] ?? []),
            currentLocationCity: doc.data['currentLocationCity'] ?? '',
            // Tambahkan field lain sesuai model Vehicle Anda
          ))
      .toList();
});

// Provider detail kendaraan (dummy, bisa disesuaikan ke database jika perlu)
final bookedVehicleDetailProvider =
    FutureProvider.family<Vehicle?, String>((ref, vehicleId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (vehicleId == "VEHICLE_ID_CAMRY") {
    return Vehicle(
      id: vehicleId,
      name: 'Toyota Camry',
      plateNumber: 'B 1234 XYZ',
      rentalPricePerDay: 500000,
      status: 'available',
      imageUrls: ['assets/images/Toyota Camry.jpg'],
      currentLocationCity: 'Jakarta',
    );
  }
  return null;
});

// Provider untuk list gambar baru (XFile, lintas platform)
final newSelectedImagesProvider = StateProvider<List<XFile>>((ref) => []);
