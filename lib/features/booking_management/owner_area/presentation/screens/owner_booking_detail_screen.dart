// lib/features/booking_management/presentation/screens/owner_booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart'
    as booking_providers;
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart'
    as vehicle_model;
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

class OwnerBookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const OwnerBookingDetailScreen({super.key, required this.bookingId});

  // --- Warna Sesuai Desain (Bisa juga dari AppTheme) ---
  static const Color backgroundColor = Color(0xFF1A2E1A);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Color(0xFFB0BEC5);
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
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: labelColor,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 15, color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label,
      VoidCallback onPressed, Color buttonColor,
      {Color textColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: Text(label, style: TextStyle(color: textColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync =
        ref.watch(booking_providers.bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Booking Details',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: bookingAsync.when(
        data: (Booking? booking) {
          if (booking == null) {
            return Center(
                child: Text('Booking not found.',
                    style: TextStyle(color: textColor)));
          }

          final vehicleAsync = ref.watch(
              vehicle_providers.bookedVehicleDetailProvider(booking.vehicleId));

          final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
          final currencyFormat = NumberFormat.currency(
              locale: 'en_US', symbol: '\$', decimalDigits: 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                _buildInfoRow('Customer Name', booking.customerName),
                _buildInfoRow('Phone Number', booking.customerPhone),
                _buildInfoRow('Email Address', booking.customerEmail),
                const SizedBox(height: 20),

                Text('Car Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                vehicleAsync.when(
                  data: (vehicle_model.Vehicle? vehicle) {
                    if (vehicle == null) {
                      return Text('Car details not available.',
                          style: TextStyle(color: subTextColor));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Car Model', vehicle.name),
                        _buildInfoRow('License Plate', vehicle.plateNumber),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(
                      color: primaryButtonColor),
                  error: (e, s) => Text('Error loading car details.',
                      style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(height: 20),

                Text('Rental Period',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                _buildInfoRow(
                    'Start Date', dateFormat.format(booking.startDate)),
                _buildInfoRow('End Date', dateFormat.format(booking.endDate)),
                const SizedBox(height: 20),

                Text('Payment Information',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                _buildInfoRow(
                    'Total Price', currencyFormat.format(booking.totalPrice)),
                _buildInfoRow(
                    'Current Status', // Label diubah agar lebih jelas
                    booking.status),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('View Payment Proof',
                      style: TextStyle(
                          color: labelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.image_outlined, color: subTextColor),
                  onTap: () {
                    print('View Payment Proof Tapped');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('View Payment Proof (Not Implemented)')),
                    );
                  },
                ),
                const SizedBox(height: 20),

                Text(
                    'Owner Notes', // Label diubah, (Optional) dihilangkan dari UI
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue:
                      booking.ownerNotes, // jika ownerNotes sudah String
                  // atau initialValue: booking.ownerNotes ?? '', jika String?
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Add notes for customer or internal reference...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: primaryButtonColor.withOpacity(0.7),
                          width: 1.5),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    // TODO: Logika untuk menyimpan notes. Mungkin ada tombol "Save Notes" terpisah
                    // atau notes disimpan saat aksi utama (confirm/reject) dilakukan.
                    // Untuk sekarang, value ini bisa disimpan ke state sementara jika perlu.
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Aksi berdasarkan status booking
                if (booking.status == 'pending_owner_confirmation' ||
                    booking.status == 'pending_payment')
                  _buildActionButton(
                      context, 'Confirm Payment & Approve Booking', () {
                    // TODO: Panggil service untuk update status booking & payment
                    print('Confirm Payment & Approve Tapped');
                  }, primaryButtonColor),

                if (booking.status == 'pending_owner_confirmation' ||
                    booking.status == 'pending_payment')
                  _buildActionButton(context, 'Reject Payment/Booking', () {
                    // TODO: Panggil service untuk update status booking & payment (mungkin perlu dialog alasan)
                    print('Reject Payment/Booking Tapped');
                  }, destructiveButtonColor,
                      textColor: Colors.white.withOpacity(0.9)),

                if (booking.status == 'confirmed' ||
                    booking.status == 'payment_verified')
                  _buildActionButton(context, 'Mark Car Picked Up', () {
                    // TODO: Update status booking ke 'on_rent'
                    print('Mark Car Picked Up Tapped');
                  }, secondaryButtonColor,
                      textColor: Colors.white.withOpacity(0.9)),

                if (booking.status == 'on_rent')
                  _buildActionButton(context, 'Mark Car Returned', () {
                    // TODO: Update status booking ke 'completed' (atau 'pending_final_check')
                    print('Mark Car Returned Tapped');
                  }, secondaryButtonColor,
                      textColor: Colors.white.withOpacity(0.9)),
              ],
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: primaryButtonColor)),
        error: (e, s) => Center(
            child:
                Text('Error: $e', style: TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
