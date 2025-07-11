import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_booking_detail_screen.dart';

class CustomerMyBookingsMultiSelectScreen extends ConsumerStatefulWidget {
  const CustomerMyBookingsMultiSelectScreen({super.key});

  @override
  ConsumerState<CustomerMyBookingsMultiSelectScreen> createState() =>
      _CustomerMyBookingsMultiSelectScreenState();
}

class _CustomerMyBookingsMultiSelectScreenState
    extends ConsumerState<CustomerMyBookingsMultiSelectScreen> {
  final Set<String> _selectedBookingIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String bookingId) {
    setState(() {
      if (_selectedBookingIds.contains(bookingId)) {
        _selectedBookingIds.remove(bookingId);
      } else {
        _selectedBookingIds.add(bookingId);
      }
      _isSelectionMode = _selectedBookingIds.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBookingIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedBookings(BuildContext context) async {
    if (_selectedBookingIds.isEmpty) return;
    if (!mounted) return; // Check if widget is still mounted

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Yakin ingin menghapus ${_selectedBookingIds.length} pesanan terpilih?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Check mounted again
      final bookingService = ref.read(bookingServiceProvider);
      int success = 0;
      for (final id in _selectedBookingIds) {
        try {
          await bookingService.deleteBooking(id);
          success++;
        } catch (_) {}
      }
      ref.invalidate(customerBookingsProvider);
      if (mounted) {
        // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil menghapus $success pesanan.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(customerBookingsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF223422),
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? 'Pilih Pesanan' : 'Riwayat Pesanan',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF223422),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus Pesanan',
              onPressed: () => _deleteSelectedBookings(context),
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Batal',
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final riwayat = bookings
              .where((b) => b.status == 'completed' || b.status == 'rejected')
              .toList();
          if (riwayat.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat pesanan.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: riwayat.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = riwayat[index];
              final selected =
                  booking.id != null &&
                  _selectedBookingIds.contains(booking.id!);
              return GestureDetector(
                onLongPress: () => _toggleSelection(booking.id ?? ''),
                onTap: _isSelectionMode
                    ? () => _toggleSelection(booking.id ?? '')
                    : () {
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
                child: Card(
                  color: selected ? Colors.red[100] : const Color(0xFF223422),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: selected,
                      onChanged: (_) => _toggleSelection(booking.id ?? ''),
                      activeColor: Colors.redAccent,
                    ),
                    title: Text(
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
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Status: ${booking.status}',
                          style: TextStyle(
                            color: booking.status == 'completed'
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
