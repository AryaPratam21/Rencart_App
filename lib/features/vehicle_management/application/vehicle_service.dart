import 'package:appwrite/appwrite.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';

class VehicleService {
  final Databases databases;
  final Storage storage;

  VehicleService(Client client)
      : databases = Databases(client),
        storage = Storage(client);

  // --- TAMBAHKAN FUNGSI INI ---
  String getFilePreviewUrl(String fileId) {
    try {
      // Menggunakan SDK untuk membuat URL yang 100% valid
      return storage.getFilePreview(
        bucketId: AppConstants.vehicleImagesBucketId, // Ganti dengan ID bucket Anda
        fileId: fileId,
        quality: 60, // Kualitas thumbnail
      ).toString();
    } catch (e) {
      print('Error generating preview URL for fileId: $fileId - $e');
      return '';
    }
  }
}
