import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/widgets/location_preview_card.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

// Extension untuk capitalize string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

final singleBookingProvider = FutureProvider.family<Booking?, String>((
  ref,
  id,
) async {
  final bookingService = ref.read(bookingServiceProvider);
  try {
    final response = await bookingService.getBookingById(id);
    return response;
  } catch (e) {
    return null;
  }
});

class CustomerBookingDetailScreen extends ConsumerWidget {
  const CustomerBookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(singleBookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) {
            return const Center(
              child: Text(
                'Booking tidak ditemukan',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final statusColor = booking.status.toLowerCase() == 'pending'
              ? Colors.orange
              : booking.status.toLowerCase() == 'confirmed'
              ? Colors.green
              : Colors.red;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID Booking: ${booking.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Tanggal Booking: ${booking.startDate.toLocal()} - ${booking.endDate.toLocal()}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.status.capitalize(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection('Detail Kendaraan', [
                  Consumer(
                    builder: (context, ref, child) {
                      final vehicleAsync = ref.watch(
                        vehicle_providers.vehicleDetailProvider(
                          booking.vehicleId,
                        ),
                      );
                      return vehicleAsync.when(
                        data: (vehicle) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama: ${vehicle.name}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Nomor Polisi: ${vehicle.plate_number}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Harga: Rp ${vehicle.rentalPricePerDay.toStringAsFixed(0)}/hari',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8BC34A),
                          ),
                        ),
                        error: (error, stackTrace) => Text(
                          'Data kendaraan tidak tersedia',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Detail Pelanggan', [
                  Text(
                    'Nama: ${booking.customerName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'No. HP: ${booking.customerPhone}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Email: ${booking.customerEmail}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Detail Pembayaran', [
                  Text(
                    'Total: Rp ${booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Metode Pembayaran: ${booking.paymentMethod}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ]),
                const SizedBox(height: 24),
                if (booking.location != null && booking.location!.isNotEmpty)
                  LocationPreviewCard(
                    address: booking.location!,
                    latitude: booking.latitude ?? 0.0,
                    longitude: booking.longitude ?? 0.0,
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF8BC34A)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF253825),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
