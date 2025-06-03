import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart';

// --- Konstanta Appwrite ---
const String appwriteDatabaseId =
    '68356389002850d27576'; // Ganti dengan ID asli
const String vehiclesCollectionId = 'vehicles'; // Ganti jika berbeda
const String vehicleImagesBucketId = 'vehicle_images'; // Ganti jika berbeda

// --- Provider Appwrite ---
final appwriteClientProvider = Provider<Client>((ref) {
  return Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e'); // Ganti dengan project ID Anda
});

final appwriteDatabasesProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

// --- Service ---
class VehicleService {
  final Databases _databases;
  final Storage _storage;

  VehicleService(this._databases, this._storage);

  Future<void> addVehicle(
      Vehicle vehicleData, List<XFile> imageFilesToUpload) async {
    try {
      List<String> uploadedImageUrls = [];
      if (imageFilesToUpload.isNotEmpty) {
        uploadedImageUrls = await _uploadImages(imageFilesToUpload);
      }

      final vehicleJson =
          vehicleData.copyWith(imageUrls: uploadedImageUrls).toJson();
      vehicleJson.removeWhere((key, value) => key == 'id' && value == null);

      await _databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: vehiclesCollectionId,
        documentId: ID.unique(),
        data: vehicleJson,
      );
      print('Vehicle added successfully: ${vehicleData.name}');
    } on AppwriteException catch (e) {
      print('Appwrite Error adding vehicle: ${e.message}');
      throw Exception(
          'Failed to add vehicle: ${e.message ?? "Unknown Appwrite error"}');
    } catch (e) {
      print('Unexpected Error adding vehicle: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateVehicle(Vehicle updatedVehicleData,
      List<XFile> newImageFilesToUpload, List<String> initialImageUrls) async {
    if (updatedVehicleData.id == null) {
      throw Exception("Vehicle ID is required for update.");
    }
    try {
      List<String> finalImageUrls = List.from(updatedVehicleData.imageUrls);

      // Hapus gambar lama dari storage jika URL-nya tidak ada lagi di finalImageUrls
      List<String> urlsToDelete = initialImageUrls
          .where((url) => !finalImageUrls.contains(url))
          .toList();
      for (String urlToDelete in urlsToDelete) {
        try {
          final fileId = urlToDelete.split('/files/')[1].split('/view')[0];
          await _storage.deleteFile(
              bucketId: vehicleImagesBucketId, fileId: fileId);
          print('Deleted old image from storage: $fileId');
        } catch (e) {
          print('Failed to delete old image $urlToDelete: $e');
        }
      }

      // Upload gambar baru
      if (newImageFilesToUpload.isNotEmpty) {
        List<String> newlyUploadedUrls =
            await _uploadImages(newImageFilesToUpload);
        finalImageUrls.addAll(newlyUploadedUrls);
      }

      final vehicleJson =
          updatedVehicleData.copyWith(imageUrls: finalImageUrls).toJson();
      vehicleJson.remove('id');

      await _databases.updateDocument(
        databaseId: appwriteDatabaseId,
        collectionId: vehiclesCollectionId,
        documentId: updatedVehicleData.id!,
        data: vehicleJson,
      );
      print('Vehicle updated successfully: ${updatedVehicleData.name}');
    } on AppwriteException catch (e) {
      print('Appwrite Error updating vehicle: ${e.message}');
      throw Exception(
          'Failed to update vehicle: ${e.message ?? "Unknown Appwrite error"}');
    } catch (e) {
      print('Unexpected Error updating vehicle: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<String>> _uploadImages(List<XFile> imageFiles) async {
    List<String> imageUrls = [];
    for (var imageFile in imageFiles) {
      try {
        final uploadedFile = await _storage.createFile(
          bucketId: vehicleImagesBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: imageFile.path, // pastikan pakai File dari dart:io
            filename: imageFile.name,
          ),
        );
        // URL preview file Appwrite
        final url =
            'https://cloud.appwrite.io/v1/storage/buckets/$vehicleImagesBucketId/files/${uploadedFile.$id}/view?project=68350fb100246925095e';
        imageUrls.add(url);
        print('Image uploaded: ${uploadedFile.$id}, URL: $url');
      } on AppwriteException catch (e) {
        print('Gagal mengupload gambar: ${e.message}');
        rethrow;
      }
    }
    return imageUrls;
  }

  Future<List<Vehicle>> getOwnerVehicles() async {
    try {
      final result = await _databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: vehiclesCollectionId,
        queries: [Query.orderDesc('\$createdAt')],
      );
      return result.documents
          .map((doc) => Vehicle.fromJson(doc.data, doc.$id))
          .toList();
    } on AppwriteException catch (e) {
      print('Gagal mengambil owner vehicles: ${e.message}');
      throw Exception(
          'Failed to load owner vehicles: ${e.message ?? "Unknown Appwrite error"}');
    }
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      final result = await _databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: vehiclesCollectionId,
        queries: [
          Query.equal('status', 'available'),
          Query.orderDesc('\$createdAt')
        ],
      );
      return result.documents
          .map((doc) => Vehicle.fromJson(doc.data, doc.$id))
          .toList();
    } on AppwriteException catch (e) {
      print('Gagal mengambil available vehicles: ${e.message}');
      throw Exception(
          'Failed to load available vehicles: ${e.message ?? "Unknown Appwrite error"}');
    }
  }

  Future<Vehicle?> getVehicleById(String vehicleId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: vehiclesCollectionId,
        documentId: vehicleId,
      );
      return Vehicle.fromJson(document.data, document.$id);
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        print('Vehicle with ID $vehicleId not found: ${e.message}');
        return null;
      }
      print('Gagal mengambil detail vehicle by ID: $vehicleId - ${e.message}');
      throw Exception(
          'Failed to load vehicle detail: ${e.message ?? "Unknown Appwrite error"}');
    }
  }
}

// --- Riverpod Providers ---
final vehicleServiceProvider = Provider<VehicleService>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final storage = ref.watch(appwriteStorageProvider);
  return VehicleService(databases, storage);
});

final ownerVehiclesProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getOwnerVehicles();
});

final availableVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final vehicleService = ref.read(vehicleServiceProvider);
  // Ambil data dari backend (Appwrite, Firebase, REST API, dll)
  return await vehicleService.getAvailableVehicles();
});

final vehicleDetailProvider =
    FutureProvider.autoDispose.family<Vehicle?, String>((ref, vehicleId) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return vehicleService.getVehicleById(vehicleId);
});
