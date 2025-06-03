import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'; // Impor VehicleService dan ownerVehiclesProvider

// State untuk form, bisa juga berupa class jika lebih kompleks
// Untuk sekarang, kita hanya peduli dengan status loading/error/success dari operasi save
// Kita bisa menggunakan AsyncValue langsung dari AsyncNotifier

// Notifier untuk menangani logika form tambah/edit kendaraan
class VehicleFormNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Tidak ada state awal yang perlu dimuat untuk operasi 'save'
    // build method ini bisa kosong atau me-return Future.value()
    return Future.value();
  }

  Future<bool> saveVehicle({
    required Vehicle vehicleData,
    required List<XFile> imageFiles, // Ubah File -> XFile
    required bool isEditMode,
  }) async {
    // Set state ke loading
    state = const AsyncLoading();

    try {
      final vehicleService = ref.read(vehicleServiceProvider);
      if (isEditMode) {
        // Asumsi Anda punya method updateVehicle di VehicleService
        // await vehicleService.updateVehicle(vehicleData, imageFiles);
        print('Simulating update vehicle: ${vehicleData.name}');
        await Future.delayed(const Duration(seconds: 1)); // Simulasi
      } else {
        await vehicleService.addVehicle(vehicleData, imageFiles); // Sudah cocok
      }
      // Jika sukses, set state ke data (bisa void jika tidak ada data yg dikembalikan)
      // dan invalidate provider daftar mobil
      state = const AsyncData(
          null); // Sukses, tidak ada data spesifik yang dikembalikan
      ref.invalidate(ownerVehiclesProvider); // Refresh daftar mobil
      return true;
    } catch (e, stackTrace) {
      // Jika gagal, set state ke error
      print('Error saving vehicle: $e');
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

// Provider untuk VehicleFormNotifier
final vehicleFormNotifierProvider =
    AsyncNotifierProvider.autoDispose<VehicleFormNotifier, void>(() {
  return VehicleFormNotifier();
});
