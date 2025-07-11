import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_booking_detail_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_my_bookings_multiselect.dart';

class CustomerBookingScreen extends ConsumerStatefulWidget {
  const CustomerBookingScreen({super.key});

  @override
  ConsumerState<CustomerBookingScreen> createState() =>
      _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends ConsumerState<CustomerBookingScreen> {
  static String _statusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'onRent':
        return 'Disewa';
      case 'completed':
        return 'Selesai';
      default:
        return status ?? '-';
    }
  }

  static Color _statusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orangeAccent;
      case 'onRent':
        return Colors.blueAccent;
      case 'completed':
        return Colors.greenAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(customerBookingsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Hapus Riwayat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CustomerMyBookingsMultiSelectScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'Anda belum memiliki pesanan.',
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                color: const Color(0xFF223422),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  title: booking.vehicleId.isEmpty
                      ? Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Mobil sudah dihapus',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          booking.vehicleId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal: ${booking.startDate.toString().split(' ').first}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Status: ${_statusText(booking.status)}',
                        style: TextStyle(
                          color: _statusColor(booking.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      (booking.status == 'completed' ||
                          booking.status == 'rejected')
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              tooltip: 'Hapus Pesanan',
                              onPressed: () async {
                                final bookingService = ref.read(
                                  bookingServiceProvider,
                                );
                                try {
                                  await bookingService.getBookingById(
                                    booking.id!,
                                  );
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Konfirmasi Hapus'),
                                      content: Text(
                                        'Yakin ingin menghapus pesanan ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await bookingService.deleteBooking(
                                      booking.id!,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Pesanan berhasil dihapus.',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal menghapus pesanan: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      : booking.status == 'pending'
                      ? Icon(Icons.hourglass_top, color: Colors.orangeAccent)
                      : booking.status == 'onRent'
                      ? Icon(
                          Icons.directions_car_filled,
                          color: Colors.blueAccent,
                        )
                      : Icon(Icons.check_circle, color: Colors.greenAccent),
                  onTap: () {
                    if (booking.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerBookingDetailScreen(
                            bookingId: booking.id!,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Gagal memuat pesanan.\n${e.toString()}',
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
