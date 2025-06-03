import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/vehicle_providers.dart';

class CustomerVehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;
  const CustomerVehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailProvider(vehicleId));
    const Color backgroundColor = Color(0xFF121212);
    const Color cardColor = Color(0xFF1E1E1E);
    const Color accentColor = Color(0xFF8BC34A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Car Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: vehicleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (vehicle) {
          if (vehicle == null) {
            return const Center(
              child: Text('Car not found',
                  style: TextStyle(color: Colors.white70)),
            );
          }
          final currencyFormatter =
              NumberFormat.currency(locale: 'en_US', symbol: '\$');
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Gambar utama
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: vehicle.imageUrls.isNotEmpty
                    ? Image.network(
                        vehicle.imageUrls.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 200,
                          color: Colors.black26,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white38, size: 60),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: Colors.black26,
                        child: const Icon(Icons.directions_car,
                            color: Colors.white38, size: 60),
                      ),
              ),
              const SizedBox(height: 18),
              // Nama dan harga
              Text(
                vehicle.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${currencyFormatter.format(vehicle.rentalPricePerDay)}/day",
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
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SpecIcon(
                      icon: Icons.people,
                      label: '${vehicle.capacity} Seats',
                    ),
                    _SpecIcon(
                      icon: Icons.settings,
                      label: (vehicle.transmission ?? '').capitalize(),
                    ),
                    _SpecIcon(
                      icon: Icons.location_on,
                      label: vehicle.currentLocationCity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Deskripsi
              const Text(
                'Description',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                vehicle.description?.isNotEmpty == true
                    ? vehicle.description!
                    : 'No description available.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),
              // Tombol Booking
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: Navigasi ke form booking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking form coming soon!'),
                        backgroundColor: accentColor,
                      ),
                    );
                  },
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
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
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// Extension untuk capitalize string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
