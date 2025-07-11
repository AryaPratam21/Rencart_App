import 'dart:io';

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';

import '../../auth/providers/auth_controller_provider.dart';
import '../domain/models/vehicle.dart';

class VehicleService {
  // ... existing fields ...

  /// Helper untuk membuat URL preview gambar Appwrite
  String getFilePreviewUrl(String fileId) {
    // Menghasilkan URL preview Appwrite Storage yang valid
    return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
  }

  final appwrite.Client client;
  final Ref ref;
  final appwrite.Storage _storage;

  VehicleService(this.client, this.ref) : _storage = appwrite.Storage(client);

  /// Tambah kendaraan baru, fileIds adalah hasil upload gambar
  Future<void> addVehicle(Vehicle vehicle, List<String> fileIds) async {
    final database = appwrite.Databases(client);

    // 1. fileIds sudah hasil upload, langsung pakai

    // 2. Buat daftar izin untuk dokumen baru
    final documentPermissions = [
      // Izinkan SEMUA PENGGUNA YANG LOGIN untuk MEMBACA detail mobil ini
      appwrite.Permission.read(appwrite.Role.users()),

      // Hanya PEMBUAT mobil (owner) yang bisa MENGUBAHNYA
      appwrite.Permission.update(appwrite.Role.user(vehicle.ownerId)),

      // Hanya PEMBUAT mobil (owner) yang bisa MENGHAPUSNYA
      appwrite.Permission.delete(appwrite.Role.user(vehicle.ownerId)),
    ];

    // 3. Buat document dengan data dari Vehicle
    final data = vehicle.toMap();
    data['image_urls'] = fileIds;
    print('[DEBUG][addVehicle] Simpan image_urls: ' + fileIds.toString());

    await database.createDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
      documentId: appwrite.ID.unique(),
      data: data,
      permissions: documentPermissions,
    );
  }

  Future<void> updateVehicle(String vehicleId, Vehicle vehicle) async {
    final database = appwrite.Databases(client);

    // 1. Upload semua gambar baru ke storage
    // Konversi URL gambar ke XFile
    final xFiles = vehicle.image_urls.map((url) => XFile(url)).toList();
    List<String> fileIds = await uploadImagesAndGetFileIds(xFiles);

    // 2. Buat daftar izin untuk dokumen
    final documentPermissions = [
      // Izinkan SEMUA PENGGUNA YANG LOGIN untuk MEMBACA detail mobil ini
      appwrite.Permission.read(appwrite.Role.users()),

      // Hanya PEMBUAT mobil (owner) yang bisa MENGUBAHNYA
      appwrite.Permission.update(appwrite.Role.user(vehicle.ownerId)),

      // Hanya PEMBUAT mobil (owner) yang bisa MENGHAPUSNYA
      appwrite.Permission.delete(appwrite.Role.user(vehicle.ownerId)),
    ];

    // 3. Update document dengan data dari Vehicle
    final data = vehicle.toMap();
    data['image_urls'] = fileIds;

    await database.updateDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
      documentId: vehicleId,
      data: data,
      permissions: documentPermissions,
    );
  }

  Future<Vehicle> getVehicleById(String vehicleId) async {
    final database = appwrite.Databases(client);

    try {
      final response = await database.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.vehiclesCollectionId,
        documentId: vehicleId,
      );

      return Vehicle.fromMap(response.data);
    } catch (e) {
      throw Exception('Gagal mengambil detail kendaraan: $e');
    }
  }

  Future<void> updateVehicleStatus(String vehicleId, String newStatus) async {
    try {
      final database = appwrite.Databases(client);

      // Update status kendaraan
      await database.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.vehiclesCollectionId,
        documentId: vehicleId,
        data: {'status': newStatus},
      );
    } catch (e) {
      throw Exception('Gagal memperbarui status kendaraan: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final database = appwrite.Databases(client);
    await database.deleteDocument(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
      documentId: vehicleId,
    );
  }

  Future<List<Vehicle>> getOwnerVehicles() async {
    final database = appwrite.Databases(client);
    final response = await database.listDocuments(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
      queries: [
        appwrite.Query.orderDesc('\$createdAt'),
        appwrite.Query.equal(
          'ownerId',
          ref.read(authControllerProvider).user?.$id ?? '',
        ),
      ],
    );
    return response.documents.map((doc) => Vehicle.fromMap(doc.data)).toList();
  }

  Future<List<Vehicle>> getVehicles() async {
    final database = appwrite.Databases(client);
    final response = await database.listDocuments(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
    );
    return response.documents.map((doc) => Vehicle.fromMap(doc.data)).toList();
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    final database = appwrite.Databases(client);

    // Get all vehicles that are available (status = 'tersedia')
    final response = await database.listDocuments(
      databaseId: AppConstants.appwriteDatabaseId,
      collectionId: AppConstants.vehiclesCollectionId,
      queries: [appwrite.Query.equal('status', 'tersedia')],
    );
    return response.documents.map((doc) => Vehicle.fromMap(doc.data)).toList();
  }

  String getImageUrl(String fileId) {
    try {
      // Pastikan endpoint dan bucket ID benar
      final endpoint = AppConstants.appwriteEndpoint;
      final bucketId = AppConstants.vehicleImagesBucketId;

      // Format URL dengan parameter yang benar
      return '$endpoint/storage/buckets/$bucketId/files/$fileId/preview?project=${AppConstants.appwriteProjectId}';
    } catch (e) {
      print("Error creating image URL for fileId $fileId: $e");
      return '';
    }
  }

  Future<String> uploadImageAndGetUrl(XFile image) async {
    try {
      // Upload gambar ke Appwrite
      final response = await _storage.createFile(
        bucketId: AppConstants.vehicleImagesBucketId,
        fileId: appwrite.ID.unique(),
        file: appwrite.InputFile(
          filename: image.name,
          path: image.path,
          contentType: image.mimeType ?? 'image/jpeg',
        ),
        permissions: [
          appwrite.Permission.read(appwrite.Role.users()),
          appwrite.Permission.write(appwrite.Role.users()),
        ],
      );

      // Kembalikan URL gambar yang valid
      return '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/${response.$id}/preview?project=${AppConstants.appwriteProjectId}';
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  Future<List<String>> uploadImagesAndGetUrls(List<XFile> images) async {
    try {
      final urls = <String>[];
      for (final image in images) {
        // Upload gambar ke Appwrite
        final response = await _storage.createFile(
          bucketId: AppConstants.vehicleImagesBucketId,
          fileId: appwrite.ID.unique(),
          file: appwrite.InputFile(
            filename: image.name,
            path: image.path,
            contentType: image.mimeType ?? 'image/jpeg',
          ),
          permissions: [
            appwrite.Permission.read(appwrite.Role.users()),
            appwrite.Permission.write(appwrite.Role.users()),
          ],
        );

        // Kembalikan URL gambar yang valid
        final imageUrl =
            '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/${response.$id}/preview?project=${AppConstants.appwriteProjectId}';
        urls.add(imageUrl);
      }
      return urls;
    } catch (e) {
      print('Error uploading multiple images: $e');
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  /// Upload gambar ke Appwrite dan return list fileId saja (BUKAN URL)
  Future<List<String>> uploadImagesAndGetFileIds(List<XFile> images, {String? userId}) async {
    try {
      final fileIds = <String>[];
      for (final image in images) {
        final response = await _storage.createFile(
          bucketId: AppConstants.vehicleImagesBucketId,
          fileId: appwrite.ID.unique(),
          file: appwrite.InputFile(
            filename: image.name,
            path: image.path,
            contentType: image.mimeType ?? 'image/jpeg',
          ),
          permissions: [
            appwrite.Permission.read(appwrite.Role.any()), // Semua user bisa view
            if (userId != null && userId.isNotEmpty)
              appwrite.Permission.write(appwrite.Role.user(userId))
            else
              appwrite.Permission.write(appwrite.Role.users()), // fallback: semua user login bisa edit
          ],
        );
        fileIds.add(response.$id);
      }
      return fileIds;
    } catch (e) {
      print('Error uploading multiple images (fileId): $e');
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }
}

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  // Dapatkan token dari state auth
  final authState = ref.watch(authControllerProvider);

  final client = appwrite.Client()
      .setEndpoint(AppConstants.appwriteEndpoint)
      .setProject(AppConstants.appwriteProjectId)
      .setSelfSigned(status: true);

  // Set JWT jika ada token
  if (authState.token != null) {
    client.setJWT(authState.token!);
  }

  return VehicleService(client, ref);
});

// Provider untuk daftar mobil dari database Appwrite
final ownerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final vehicleService = ref.watch(vehicleServiceProvider);
  return await vehicleService.getOwnerVehicles();
});

// Provider untuk list gambar yang baru dipilih (File)
final newSelectedImagesProvider = StateProvider.autoDispose<List<File>>((ref) {
  return []; // Selalu mulai dengan list kosong
});

// Provider untuk list URL gambar yang sudah ada (untuk mode edit)
final existingImageUrlsProvider = StateProvider.autoDispose
    .family<List<String>, List<String>?>((ref, initialUrls) {
      return initialUrls ?? []; // Mulai dengan URL awal atau list kosong
    });

// Provider untuk detail kendaraan
final vehicleDetailProvider = FutureProvider.family<Vehicle, String>((
  ref,
  vehicleId,
) async {
  final database = appwrite.Databases(ref.watch(vehicleServiceProvider).client);
  final response = await database.getDocument(
    databaseId: AppConstants.appwriteDatabaseId,
    collectionId: AppConstants.vehiclesCollectionId,
    documentId: vehicleId,
  );
  return Vehicle.fromMap(response.data);
});

// Provider untuk daftar kendaraan tersedia
final availableVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final database = appwrite.Databases(ref.watch(vehicleServiceProvider).client);
  final response = await database.listDocuments(
    databaseId: AppConstants.appwriteDatabaseId,
    collectionId: AppConstants.vehiclesCollectionId,
    queries: [appwrite.Query.equal('status', 'Tersedia')],
  );
  return response.documents.map((doc) => Vehicle.fromMap(doc.data)).toList();
});

// Provider untuk loading state form ini
final addEditVehicleLoadingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

// Provider untuk mengelola state form kendaraan
final vehicleFormProvider =
    StateNotifierProvider<VehicleFormNotifier, VehicleFormState>(
      (ref) => VehicleFormNotifier(ref),
    );

class VehicleFormState {
  final Vehicle vehicle;
  final List<XFile> images;
  final bool isEditMode;
  final List<String> removedOldFileIds; // fileId gambar lama yang dihapus user

  VehicleFormState({
    required this.vehicle,
    required this.images,
    this.isEditMode = false,
    this.removedOldFileIds = const [],
  });

  VehicleFormState copyWith({
    Vehicle? vehicle,
    List<XFile>? images,
    bool? isEditMode,
    List<String>? removedOldFileIds,
  }) {
    return VehicleFormState(
      vehicle: vehicle ?? this.vehicle,
      images: images ?? this.images,
      isEditMode: isEditMode ?? this.isEditMode,
      removedOldFileIds: removedOldFileIds ?? this.removedOldFileIds,
    );
  }
}

class VehicleFormNotifier extends StateNotifier<VehicleFormState> {
  final Ref ref;
  VehicleFormNotifier(this.ref)
    : super(VehicleFormState(vehicle: Vehicle.empty(), images: []));

  void setVehicle(Vehicle vehicle) {
    state = state.copyWith(vehicle: vehicle);
  }

  void setImages(List<XFile> images) {
    state = state.copyWith(images: images);
  }

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  // --- Fungsi hapus gambar lama (edit) ---
  void removeOldImage(String fileId) {
    final updatedRemoved = [...state.removedOldFileIds, fileId];
    // Hapus fileId dari image_urls di vehicle
    final updatedVehicle = state.vehicle.copyWith(
      image_urls: state.vehicle.image_urls.where((id) => id != fileId).toList(),
    );
    state = state.copyWith(
      vehicle: updatedVehicle,
      removedOldFileIds: updatedRemoved,
    );
  }

  Future<void> saveVehicle() async {
    final vehicleService = ref.read(vehicleServiceProvider);
    if (state.isEditMode) {
      if (state.vehicle.id == null) {
        throw Exception('Vehicle ID tidak valid');
      }
      // Logika edit: jika ada gambar baru, upload dan gabungkan dengan gambar lama, kecuali yang dihapus
      final user = ref.read(authControllerProvider).user;
      if (user == null) throw Exception('User tidak login');
      List<String> oldFileIds = state.vehicle.image_urls;
      List<String> newFileIds = [];
      if (state.images.isNotEmpty) {
        // Upload gambar baru
        newFileIds = await vehicleService.uploadImagesAndGetFileIds(state.images, userId: user.$id);
      }
      // Hanya fileId lama yang tidak dihapus
      final filteredOldFileIds = oldFileIds.where((id) => !state.removedOldFileIds.contains(id)).toList();
      final allFileIds = [...filteredOldFileIds, ...newFileIds];
      // Buat salinan vehicle dengan image_urls terbaru
      final updatedVehicle = state.vehicle.copyWith(image_urls: allFileIds);
      await vehicleService.updateVehicle(state.vehicle.id!, updatedVehicle);
    } else {
      // Upload gambar dulu, dapatkan fileIds
      final user = ref.read(authControllerProvider).user;
      if (user == null) throw Exception('User tidak login');
      final fileIds = await vehicleService.uploadImagesAndGetFileIds(state.images, userId: user.$id);
      await vehicleService.addVehicle(state.vehicle, fileIds);
    }
  }
}

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final service = ref.read(vehicleServiceProvider);
  final response = await service.getVehicles();
  return response;
});
