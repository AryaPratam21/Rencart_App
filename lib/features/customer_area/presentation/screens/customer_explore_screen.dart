import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_vehicle_detail_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/widgets/filter_dialogs.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/providers/filter_providers.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';

String getFilePreviewUrl(String fileId) {
  return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
}

class CustomerExploreScreen extends ConsumerWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(
      vehicle_providers.availableVehiclesProvider,
    );

    const Color secondaryTextColor = Colors.white70;
    const Color filterChipColor = Color(0xFF2F4F2F);
    const Color filterChipTextColor = Colors.white;
    const Color cardBackgroundColor = Color(0xFF253825);
    const Color primaryTextColor = Colors.white;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // State untuk filter
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedCarType = ref.watch(selectedCarTypeProvider);

    Widget buildFilterSection() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 10.0),
        child: Row(
          children: [
            Expanded(
              child: _FilterChipButtonExplore(
                label: selectedLocation.isEmpty ? 'Lokasi' : selectedLocation,
                color: filterChipColor,
                textColor: filterChipTextColor,
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => LocationFilterDialog(),
                  );
                  if (result != null) {
                    ref.read(selectedLocationProvider.notifier).state = result;
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterChipButtonExplore(
                label: selectedCarType.isEmpty ? 'Tipe Mobil' : selectedCarType,
                color: filterChipColor,
                textColor: filterChipTextColor,
                onTap: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => CarTypeFilterDialog(),
                  );
                  if (result != null) {
                    ref.read(selectedCarTypeProvider.notifier).state = result;
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Mobil'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: Column(
        children: [
          buildFilterSection(),
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                // Filter mobil berdasarkan status, lokasi, dan tipe mobil
                final filteredVehicles = vehicles.where((v) {
                  // Filter status
                  if (v.status != 'Tersedia') return false;

                  // Filter lokasi jika ada yang dipilih
                  if (selectedLocation.isNotEmpty &&
                      v.currentLocationCity.toLowerCase() !=
                          selectedLocation.toLowerCase()) {
                    return false;
                  }

                  // Filter tipe mobil jika ada yang dipilih
                  if (selectedCarType.isNotEmpty &&
                      v.transmission.toLowerCase() !=
                          selectedCarType.toLowerCase()) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filteredVehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada mobil tersedia',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedLocation.isNotEmpty ||
                                  selectedCarType.isNotEmpty
                              ? 'Coba ubah filter Anda'
                              : 'Coba gunakan filter untuk menemukan mobil yang Anda inginkan',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return Card(
                      color: cardBackgroundColor,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          // Pastikan vehicle id tidak null dan tidak kosong
                          if (vehicle.id == null || vehicle.id!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data mobil tidak lengkap'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Navigasi ke halaman detail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerVehicleDetailScreen(
                                vehicleId: vehicle.id!,
                              ),
                            ),
                          ).then((_) {
                            // Refresh data setelah kembali dari detail
                            ref.invalidate(
                              vehicle_providers.availableVehiclesProvider,
                            );
                          });
                        },
                        child: Column(
                          children: [
                            // Gambar mobil
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: vehicle.image_urls.isNotEmpty
                                      ? NetworkImage(getFilePreviewUrl(vehicle.image_urls.first))
                                      : const AssetImage(
                                              'packages/cupertino_icons/assets/CupertinoIcons-1024.png',
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Informasi mobil
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama mobil dan harga
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vehicle.name,
                                          style: const TextStyle(
                                            color: primaryTextColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${currencyFormatter.format(vehicle.rentalPricePerDay)}/hari',
                                        style: const TextStyle(
                                          color: primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Lokasi dan deskripsi
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: secondaryTextColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          vehicle.currentLocationCity,
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Deskripsi singkat
                                  Text(
                                    vehicle.description,
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Button Booking
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Pastikan vehicle id tidak null dan tidak kosong
                                      if (vehicle.id == null ||
                                          vehicle.id!.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Data mobil tidak lengkap',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerVehicleDetailScreen(
                                                vehicleId: vehicle.id!,
                                              ),
                                        ),
                                      ).then((_) {
                                        ref.invalidate(
                                          vehicle_providers
                                              .availableVehiclesProvider,
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.book),
                                    label: const Text('Booking'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2F4F2F),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        vehicle_providers.availableVehiclesProvider,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk tombol filter (bisa diberi nama berbeda)
class _FilterChipButtonExplore extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _FilterChipButtonExplore({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4.0),
              Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
