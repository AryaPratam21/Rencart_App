import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- Provider dan Model ---
enum BookingStatusFilter { pendingPayment, confirmed, onRent, completed, all }

final activeBookingStatusFilterProvider = StateProvider<BookingStatusFilter>(
    (ref) => BookingStatusFilter.pendingPayment);

final bookingServiceProvider = Provider<BookingService>((ref) {
  final client = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e'); // Ganti dengan project ID Anda
  return BookingService(client);
});

final filteredBookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final filter = ref.watch(activeBookingStatusFilterProvider);
  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getBookings(filter: filter);
});

final vehicleDetailProvider =
    FutureProvider.family<Vehicle?, String>((ref, vehicleId) async {
  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getVehicleDetails(vehicleId);
});

class BookingService {
  final appwrite.Client client;
  BookingService(this.client);

  String _filterToString(BookingStatusFilter filter) {
    switch (filter) {
      case BookingStatusFilter.pendingPayment:
        return 'pendingPayment';
      case BookingStatusFilter.confirmed:
        return 'confirmed';
      case BookingStatusFilter.onRent:
        return 'onRent';
      case BookingStatusFilter.completed:
        return 'completed';
      default:
        return '';
    }
  }

  Future<List<Booking>> getBookings({BookingStatusFilter? filter}) async {
    final database = appwrite.Databases(client);
    final response = await database.listDocuments(
      databaseId: '68350fb100246925095e', // Ganti dengan database ID Anda
      collectionId:
          '683566ce00237874d560', // Ganti dengan collection ID booking Anda
      queries: filter != null && filter != BookingStatusFilter.all
          ? [appwrite.Query.equal('status', _filterToString(filter))]
          : null,
    );
    return response.documents
        .map((doc) => Booking(
              id: doc.$id,
              customerName: doc.data['customerName'],
              startDate: DateTime.parse(doc.data['startDate']),
              endDate: DateTime.parse(doc.data['endDate']),
              vehicleId: doc.data['vehicleId'],
              totalPrice: doc.data['totalPrice'],
              status: doc.data['status'],
            ))
        .toList();
  }

  Future<Vehicle?> getVehicleDetails(String vehicleId) async {
    await Future.delayed(Duration(seconds: 1));
    return Vehicle(
      name: 'Toyota Avanza',
      imageUrls: [
        'https://example.com/images/toyota_avanza_1.jpg',
        'https://example.com/images/toyota_avanza_2.jpg',
      ],
    );
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    // Update status booking di Appwrite Database
  }
}

class Booking {
  final String id;
  final String customerName;
  final DateTime startDate;
  final DateTime endDate;
  final String vehicleId;
  final int totalPrice;
  final String status; // Tambahkan ini

  Booking({
    required this.id,
    required this.customerName,
    required this.startDate,
    required this.endDate,
    required this.vehicleId,
    required this.totalPrice,
    required this.status,
  });
}

class Vehicle {
  final String name;
  final List<String> imageUrls;

  Vehicle({
    required this.name,
    required this.imageUrls,
  });
}

// --- Widget ---
class OwnerBookingListScreen extends ConsumerWidget {
  const OwnerBookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsyncValue = ref.watch(filteredBookingsProvider);
    final activeFilter = ref.watch(activeBookingStatusFilterProvider);

    final Color backgroundColor = Color(0xFF1A2E1A);
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color tabIndicatorColor = Colors.white; // Warna indikator tab aktif
    final Color unselectedTabColor = Colors.white.withOpacity(0.6);

    return DefaultTabController(
      length: 4, // Jumlah tab (Pending, Confirmed, On Rent, Completed)
      initialIndex: BookingStatusFilter.values.indexOf(activeFilter) < 4
          ? BookingStatusFilter.values.indexOf(activeFilter)
          : 0, // Set initialIndex
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text('Bookings',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            isScrollable: true, // Jika tab banyak atau teks panjang
            indicatorColor: tabIndicatorColor,
            indicatorWeight: 3.0,
            labelColor: textColor,
            unselectedLabelColor: unselectedTabColor,
            labelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            tabs: BookingStatusFilter.values
                .where((f) => f != BookingStatusFilter.all)
                .map((filter) {
              // Filter 'all' jika tidak mau ditampilkan sebagai tab
              return Tab(text: _getFilterString(filter));
            }).toList(),
            onTap: (index) {
              // Update provider filter saat tab diganti
              // Pastikan urutan enum sesuai dengan urutan tab
              if (index < BookingStatusFilter.values.length - 1) {
                // -1 jika 'all' tidak di tab
                ref.read(activeBookingStatusFilterProvider.notifier).state =
                    BookingStatusFilter.values[index];
              }
            },
          ),
        ),
        body: bookingsAsyncValue.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return Center(
                child: Text(
                  'No bookings found for "${_getFilterString(activeFilter)}" status.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor.withOpacity(0.7), fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingListItemWidget(booking: booking);
              },
            );
          },
          loading: () => Center(
              child: CircularProgressIndicator(color: Color(0xFF8BC34A))),
          error: (error, stack) => Center(
            child: Text(
              'Error loading bookings: ${error.toString()}',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper untuk mendapatkan string dari enum filter
String _getFilterString(BookingStatusFilter filter) {
  switch (filter) {
    case BookingStatusFilter.pendingPayment:
      return 'Pending Payment';
    case BookingStatusFilter.confirmed:
      return 'Confirmed';
    case BookingStatusFilter.onRent:
      return 'On Rent';
    case BookingStatusFilter.completed:
      return 'Completed';
    default:
      return 'All';
  }
}

// --- Buat Widget Ini di File Terpisah (misal: booking_list_item_widget.dart) ---
// --- atau di bawah kelas ini jika sederhana ---
class BookingListItemWidget extends ConsumerWidget {
  // Ubah jadi ConsumerWidget
  final Booking booking;

  const BookingListItemWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsyncValue =
        ref.watch(vehicleDetailProvider(booking.vehicleId));
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color subTextColor = Colors.white.withOpacity(0.7);
    final Color priceColor = Colors.white;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      color: Color(0xFF2A402A),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vehicleAsyncValue.when(
                data: (vehicle) => ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: (vehicle != null && vehicle.imageUrls.isNotEmpty)
                      ? Image.network(
                          vehicle.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[700],
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey[400])),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[800],
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Color(0xFF8BC34A))));
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[700],
                          child: Icon(Icons.no_photography,
                              color: Colors.grey[400])),
                ),
                loading: () => Container(
                    width: 80,
                    height: 80,
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0, color: Color(0xFF8BC34A)))),
                error: (err, stack) => Container(
                    width: 80,
                    height: 80,
                    child: Icon(Icons.error_outline, color: Colors.redAccent)),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${booking.customerName}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Rental Dates: ${dateFormat.format(booking.startDate)} to ${dateFormat.format(booking.endDate)}',
                      style: TextStyle(fontSize: 13, color: subTextColor),
                    ),
                    const SizedBox(height: 2.0),
                    vehicleAsyncValue.when(
                      data: (vehicle) => Text(
                        vehicle?.name ?? 'Loading vehicle...',
                        style: TextStyle(fontSize: 13, color: subTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => Text('Loading vehicle...',
                          style: TextStyle(fontSize: 13, color: subTextColor)),
                      error: (err, stack) => Text('Vehicle N/A',
                          style: TextStyle(fontSize: 13, color: subTextColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                NumberFormat.currency(
                        locale: 'en_US', symbol: '\$', decimalDigits: 0)
                    .format(booking.totalPrice),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: priceColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
