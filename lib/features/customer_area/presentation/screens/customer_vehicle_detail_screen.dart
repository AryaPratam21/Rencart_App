import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_booking_form_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/widgets/view_location_button.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';

String getFilePreviewUrl(String fileId) {
  return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
}

class CustomerVehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;
  const CustomerVehicleDetailScreen({super.key, required this.vehicleId});

  void _showBookingForm(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CustomerBookingFormScreen(vehicle: vehicle),
          ),
        )
        .then((result) {
          if (result == true) {
            // Refresh detail kendaraan setelah booking sukses
            ref.invalidate(vehicle_providers.vehicleDetailProvider(vehicleId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pesanan berhasil dibuat!'),
                backgroundColor: Color(0xFF8BC34A),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(
      vehicle_providers.vehicleDetailProvider(vehicleId),
    );
    const Color backgroundColor = const Color(0xFF1F2C2E);
    const Color cardColor = const Color(0xFF1A2426);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Mobil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: vehicleAsync.when(
        data: (vehicle) {
          final rentalPrice = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(vehicle.rentalPricePerDay);

          // Check vehicle status
          if (vehicle.status != 'Tersedia') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.do_not_disturb_on,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Maaf, mobil ini sedang tidak tersedia.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                // Gambar mobil
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: vehicle.image_urls.isNotEmpty
                        ? Image.network(
                            getFilePreviewUrl(vehicle.image_urls.first),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                // Nama dan harga
                Text(
                  StringExtension(vehicle.name).capitalize(),
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  "$rentalPrice/hari",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                // Info spesifikasi
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SpecIcon(
                        icon: Icons.people,
                        label: '${vehicle.capacity} Kursi',
                      ),
                      _SpecIcon(
                        icon: Icons.settings,
                        label: StringExtension(
                          vehicle.transmission,
                        ).capitalize(),
                      ),
                      _SpecIcon(
                        icon: Icons.location_city,
                        label: vehicle.currentLocationCity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ViewLocationButton(
                  latitude: vehicle.latitude,
                  longitude: vehicle.longitude,
                  address: vehicle.location,
                ),
                const SizedBox(height: 18),
                // Badge jika mobil tidak available
                if (vehicle.status != 'Tersedia')
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                // Deskripsi
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  vehicle.description.isEmpty
                      ? 'Tidak ada deskripsi yang tersedia.'
                      : vehicle.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 28),
                // Status dan tombol Booking
                if (vehicle.status != 'Tersedia')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.status == 'on_rent'
                          ? Colors.red.withOpacity(0.9)
                          : Colors.orange.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.status == 'on_rent'
                          ? 'Mobil sedang disewa'
                          : 'Mobil tidak tersedia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showBookingForm(context, ref, vehicle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8BC34A),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Booking Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SpecIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
