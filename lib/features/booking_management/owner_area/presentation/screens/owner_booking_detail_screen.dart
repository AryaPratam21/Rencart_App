// lib/features/booking_management/presentation/screens/owner_booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart'
    as booking_providers;
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

class OwnerBookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final void Function(String)? onStatusChanged;

  const OwnerBookingDetailScreen({
    super.key,
    required this.bookingId,
    this.onStatusChanged,
  });

  @override
  ConsumerState<OwnerBookingDetailScreen> createState() =>
      _OwnerBookingDetailScreenState();
}

class _OwnerBookingDetailScreenState
    extends ConsumerState<OwnerBookingDetailScreen> {
  late TextEditingController _ownerNotesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ownerNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _ownerNotesController.dispose();
    super.dispose();
  }

  // --- UI Theme Colors ---
  static const Color backgroundColor = Color(0xFF1A2E1A);
  static const Color textColor = Colors.white;
  static const Color labelColor = Color(0xFFCFD8DC);
  static const Color cardColor = Color(0xFF2A402A);
  static const Color primaryButtonColor = Color(0xFF8BC34A);
  static const Color secondaryButtonColor = Color(0xFF3A5A3A);
  static const Color destructiveButtonColor = Color(0xFF522E2E);

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
    Color buttonColor, {
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: Text(label, style: TextStyle(color: textColor)),
      ),
    );
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final bookingService = ref.read(booking_providers.bookingServiceProvider);
      await bookingService.updateBookingStatus(widget.bookingId, newStatus);

      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(newStatus);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah ke $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(
      booking_providers.bookingDetailProvider(widget.bookingId),
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Booking Details',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          body: bookingAsync.when(
            data: (booking) {
              if (booking == null) {
                return Center(
                  child: Text(
                    'Booking not found.',
                    style: TextStyle(color: textColor),
                  ),
                );
              }

              _ownerNotesController.text = booking.ownerNotes ?? '';

              final vehiclesAsync = ref.watch(
                vehicle_providers.ownerVehiclesProvider,
              );
              final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
              final currencyFormat = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Customer Name', booking.customerName),
                    _buildInfoRow('Phone Number', booking.customerPhone),
                    _buildInfoRow('Email Address', booking.customerEmail),
                    const SizedBox(height: 20),

                    Text(
                      'Car Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    vehiclesAsync.when(
                      data: (List<Vehicle> vehicles) {
                        Vehicle? vehicle;
                        try {
                          // Get the vehicle using vehicleId from Booking
                          vehicle = vehicles.firstWhere(
                            (v) => v.id == booking.vehicleId,
                            orElse: () => Vehicle.empty(),
                          );
                          // Check if vehicle is empty
                          if (vehicle.name.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.warning, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Kendaraan tidak ditemukan\n(ID: ${booking.vehicleId})',
                                    style: TextStyle(color: Colors.redAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          vehicle = null;
                        }

                        if (vehicle == null) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.warning, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text(
                                  'Kendaraan tidak ditemukan\n(ID: ${booking.vehicleId})',
                                  style: TextStyle(color: Colors.redAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Car Model', vehicle.name),
                            _buildInfoRow(
                              'License Plate',
                              vehicle.plate_number,
                            ),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(
                        color: primaryButtonColor,
                      ),
                      error: (e, s) => Text(
                        'Error loading car details.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Rental Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Start Date',
                      dateFormat.format(booking.startDate),
                    ),
                    _buildInfoRow(
                      'End Date',
                      dateFormat.format(booking.endDate),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Payment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Total Price',
                      currencyFormat.format(booking.totalPrice),
                    ),
                    _buildInfoRow('Status Saat Ini', booking.status),
                    const SizedBox(height: 20),

                    Text(
                      'Catatan Pemilik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _ownerNotesController,
                      maxLines: 3,
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText:
                            'Tambahkan catatan untuk pelanggan atau referensi internal...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: primaryButtonColor.withOpacity(0.7),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (booking.id == null) return;
                          final notes = _ownerNotesController.text;
                          try {
                            await ref
                                .read(booking_providers.bookingServiceProvider)
                                .updateOwnerNotes(booking.id!, notes);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notes saved successfully!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Notes'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons based on booking status (Cash Flow)
                    if (booking.status == 'pending_confirmation') ...[
                      _buildActionButton(
                        context,
                        'Konfirmasi Pembayaran Cash & Mulai Sewa',
                        () async {
                          await _updateBookingStatus('on_rent');
                          ref.invalidate(
                            booking_providers.bookingDetailProvider(
                              widget.bookingId,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Booking berhasil dikonfirmasi dan status disewa!',
                              ),
                            ),
                          );
                          // Arahkan ke halaman pesanan customer (tab "Pesanan")
                          Navigator.of(context).pop();
                        },
                        primaryButtonColor,
                        textColor:
                            Colors.black87, // Black text for light green button
                      ),
                      _buildActionButton(context, 'Tolak Booking', () async {
                        await _updateBookingStatus('rejected');
                        ref.invalidate(
                          booking_providers.bookingDetailProvider(
                            widget.bookingId,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking ditolak!')),
                        );
                      }, destructiveButtonColor),
                    ],
                    if (booking.status == 'pending_payment')
                      _buildActionButton(
                        context,
                        'Batalkan Sewa & Tandai Ditolak',
                        () async {
                          if (booking.id == null) return;
                          await _updateBookingStatus('rejected');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking dibatalkan dan ditolak!'),
                            ),
                          );
                        },
                        destructiveButtonColor,
                      ),
                    if (booking.status == 'pending_payment')
                      _buildActionButton(context, 'Mulai Sewa', () async {
                        if (booking.id == null) return;
                        await _updateBookingStatus('on_rent');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking dimulai!')),
                        );
                      }, primaryButtonColor),
                    if (booking.status == 'on_rent')
                      _buildActionButton(
                        context,
                        'Selesaikan Sewa & Tandai Selesai',
                        () async {
                          if (booking.id == null) return;
                          await _updateBookingStatus('completed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Booking selesai!')),
                          );
                        },
                        secondaryButtonColor,
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: primaryButtonColor),
            ),
            error: (e, s) => Center(
              child: Text(
                'Error: $e',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: primaryButtonColor),
            ),
          ),
      ],
    );
  }
}
