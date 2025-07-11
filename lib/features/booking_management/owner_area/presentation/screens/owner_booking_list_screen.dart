import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/owner_area/presentation/screens/owner_booking_detail_screen.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

// --- Widget ---
class OwnerBookingListScreen extends ConsumerWidget {
  const OwnerBookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A2E1A),
        appBar: AppBar(
          automaticallyImplyLeading: false, // Menghilangkan tombol back
          title: const Text('Pesanan'),
          backgroundColor: const Color(0xFF1F1F1F),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(ownerBookingsProvider);
                print("Manually refreshing owner bookings...");
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disewa'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Hanya render satu ListView per tab, tidak ada duplikasi
            _buildBookingList(context, ref, [
              'pending_confirmation',
            ], 'Tidak ada pesanan menunggu.'),
            _buildBookingList(context, ref, [
              'on_rent',
            ], 'Tidak ada pesanan yang sedang disewa.'),
            _buildBookingList(context, ref, [
              'completed',
              'rejected',
            ], 'Tidak ada riwayat pesanan.'),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk menghindari duplikasi kode
  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    List<String> statuses,
    String emptyMessage,
  ) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final filteredBookings = bookings
            .where((b) => statuses.contains(b.status))
            .toList();
        if (filteredBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 60, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];

            // Get vehicle details
            final vehicleAsync = ref.watch(
              vehicle_providers.ownerVehiclesProvider,
            );

            // Cari vehicle yang sesuai dengan booking
            final vehicle = vehicleAsync.when(
              data: (vehicles) => vehicles.firstWhere(
                (v) => v.id == booking.vehicleId,
                orElse: () => Vehicle(
                  id: '',
                  name: 'Mobil tidak ditemukan',
                  ownerId: '',
                  status: 'Tersedia',
                  plate_number: '',
                  rentalPricePerDay: 0,
                  image_urls: [],
                  capacity: 0,
                  transmission: '',
                  description: '',
                  currentLocationCity: '',
                  location: '',
                  latitude: 0.0,
                  longitude: 0.0,
                ),
              ),
              loading: () => Vehicle(
                id: '',
                name: 'Loading...',
                ownerId: '',
                status: 'Tersedia',
                plate_number: '',
                rentalPricePerDay: 0,
                image_urls: [],
                capacity: 0,
                transmission: '',
                description: '',
                currentLocationCity: '',
                location: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
              error: (_, __) => Vehicle(
                id: '',
                name: 'Error loading vehicle',
                ownerId: '',
                status: 'Tersedia',
                plate_number: '',
                rentalPricePerDay: 0,
                image_urls: [],
                capacity: 0,
                transmission: '',
                description: '',
                currentLocationCity: '',
                location: '',
                latitude: 0.0,
                longitude: 0.0,
              ),
            );

            return Card(
              color: const Color(0xFF1A2426),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    vehicle.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  vehicle.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pelanggan: ${booking.customerName}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy').format(booking.startDate)} - ${DateFormat('dd MMM yyyy').format(booking.endDate)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Status: ${_getStatusText(booking.status)}',
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    if (booking.id == null) return;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            OwnerBookingDetailScreen(bookingId: booking.id!),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_confirmation':
        return 'Menunggu Konfirmasi';
      case 'on_rent':
        return 'Disewa';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_confirmation':
        return Colors.orange;
      case 'on_rent':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}
