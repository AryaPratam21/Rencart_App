import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/widgets/view_location_button.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/vehicle_booking_providers.dart';

// --- MODEL DATA DUMMY (Hanya untuk contoh UI ini) ---
class CarDetailBooking {
  final String customerName;
  final DateTime startDate;
  final DateTime endDate;

  CarDetailBooking({
    required this.customerName,
    required this.startDate,
    required this.endDate,
  });
}

// --- PROVIDER LOKAL UNTUK STATUS TERPILIH ---
// .family digunakan agar setiap instance CarDetailScreen dengan vehicleId berbeda
// memiliki state statusnya sendiri.
final _selectedStatusProvider = StateProvider.family<String?, String>((
  ref,
  vehicleId,
) {
  // Nilai awal akan di-set saat data mobil dimuat
  return null;
});

// --- WIDGET UTAMA ---
class OwnerCarDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId; // ID mobil yang akan ditampilkan

  const OwnerCarDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<OwnerCarDetailScreen> createState() =>
      _OwnerCarDetailScreenState();
}

class _OwnerCarDetailScreenState extends ConsumerState<OwnerCarDetailScreen> {
  // Data mobil dummy (GANTI DENGAN PROVIDER APPWRITE ANDA)
  Vehicle? _vehicle;
  String? _errorMessage;
  bool _isLoading = true;
  List<CarDetailBooking> _bookingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    try {
      final vehicle = await ref.read(
        vehicle_providers.vehicleDetailProvider(widget.vehicleId).future,
      );
      setState(() {
        _vehicle = vehicle;
        // Initialize booking history with dummy data
        _bookingHistory = [
          CarDetailBooking(
            customerName: "Ava Carter",
            startDate: DateTime(2024, 7, 15),
            endDate: DateTime(2024, 7, 20),
          ),
          CarDetailBooking(
            customerName: "Ethan Harper",
            startDate: DateTime(2024, 6, 10),
            endDate: DateTime(2024, 6, 12),
          ),
        ];
        // Initialize status provider with vehicle status
        ref.read(_selectedStatusProvider(widget.vehicleId).notifier).state =
            _vehicle?.status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data mobil: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges(String newStatus) async {
    if (_vehicle == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleService = ref.read(vehicle_providers.vehicleServiceProvider);
      await vehicleService.updateVehicle(
        _vehicle!.id!, // ID vehicle
        _vehicle!.copyWith(status: newStatus), // Vehicle object
      );

      setState(() {
        _vehicle = _vehicle!.copyWith(status: newStatus);
      });
      ref.read(_selectedStatusProvider(widget.vehicleId).notifier).state =
          newStatus;

      ref.invalidate(vehicle_providers.vehicleDetailProvider(widget.vehicleId));
      ref.invalidate(vehicle_providers.ownerVehiclesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? selectedStatus = ref.watch(
      _selectedStatusProvider(widget.vehicleId),
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(
          title: const Text(
            'Detail Mobil',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A2426),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFB2D3A8)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(
          title: const Text(
            'Detail Mobil',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A2426),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    if (_vehicle == null) {
      // Seharusnya tidak terjadi jika _errorMessage null dan _isLoading false, tapi sebagai fallback
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(
          title: const Text(
            'Detail Mobil',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A2426),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            "Tidak ada data mobil yang tersedia.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Jika _vehicle tidak null, kita bisa aman mengaksesnya
    final car = _vehicle!;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2C2E),
      appBar: AppBar(
        title: const Text(
          'Detail Mobil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A2466),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (car.image_urls.isNotEmpty)
              Image.network(
                '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/${car.image_urls.first}/preview',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB2D3A8),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 250,
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Nomor Polisi:', car.plate_number),
                  if (car.vin != null) _buildDetailRow('VIN:', car.vin!),
                  if (car.mileage != null)
                    _buildDetailRow(
                      'Jarak Tempuh:',
                      '${NumberFormat.decimalPattern().format(car.mileage)} mil',
                    ),
                  _buildDetailRow('Lokasi:', car.location),
                  const SizedBox(height: 8),
                  if (car.location.isNotEmpty)
                    ViewLocationButton(
                      latitude: car.latitude,
                      longitude: car.longitude,
                      address: car.location,
                    ),
                  _buildDetailRow('Transmisi:', car.transmission),
                  _buildDetailRow('Kapasitas:', '${car.capacity} kursi'),
                  if (car.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Deskripsi:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Text(
                    'Status',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0,
                    children: ['available', 'rented', 'maintenance'].map((
                      statusOption,
                    ) {
                      // Hanya 3 status seperti di gambar
                      final isSelected = selectedStatus == statusOption;
                      return ChoiceChip(
                        label: Text(
                          statusOption.capitalize(),
                          style: TextStyle(
                            color: isSelected ? Colors.black87 : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                    .read(
                                      _selectedStatusProvider(
                                        widget.vehicleId,
                                      ).notifier,
                                    )
                                    .state =
                                statusOption;
                          }
                        },
                        selectedColor: const Color(0xFFB2D3A8),
                        backgroundColor: const Color(0xFF2A3A3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFB2D3A8)
                                : const Color(0xFF4A5C5F),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ), // Sesuaikan padding
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Riwayat Pesanan Selesai',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final bookingsAsync = ref.watch(
                        vehicleBookingsProvider(widget.vehicleId),
                      );
                      return bookingsAsync.when(
                        data: (bookings) {
                          if (bookings.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada pesanan selesai untuk mobil ini.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: bookings.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.white24),
                            itemBuilder: (context, idx) {
                              final booking = bookings[idx];
                              return ListTile(
                                leading: const Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.greenAccent,
                                ),
                                title: Text(
                                  booking.customerName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd MMM yyyy').format(booking.startDate)} - ${DateFormat('dd MMM yyyy').format(booking.endDate)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Text(
                                  'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(
                          child: Text(
                            'Gagal memuat data booking',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Riwayat Pemesanan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_bookingHistory.isEmpty)
                    const Text(
                      'Tidak ada riwayat pemesanan untuk mobil ini.',
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bookingHistory.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFF2A3A3D), height: 1),
                      itemBuilder: (context, index) {
                        final booking = _bookingHistory[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: _getAvatarColor(
                              booking.customerName,
                            ), // Warna avatar acak sederhana
                            child: Text(
                              booking.customerName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            booking.customerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${DateFormat.yMMMd().format(booking.startDate)} - ${DateFormat.yMMMd().format(booking.endDate)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40), // Beri ruang lebih sebelum tombol
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB2D3A8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed:
                        (selectedStatus != null && selectedStatus != car.status)
                        ? () {
                            _saveChanges(selectedStatus);
                          }
                        : null, // Disable tombol jika status tidak berubah
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(color: Color(0xFF1F2C2E)),
                    ),
                  ),
                ],
              ), // <-- tutup Column children
            ), // <-- tutup Padding
          ],
        ), // <-- tutup Column utama
      ), // <-- tutup SingleChildScrollView
    ); // <-- tutup Scaffold
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  final List<Color> _avatarColors = [
    // Warna untuk avatar dummy
    Colors.blueGrey,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.brown,
  ];

  Color _getAvatarColor(String name) {
    final hash = name.hashCode;
    final index = hash % _avatarColors.length;
    return _avatarColors[index];
  }
}

// Extension untuk capitalize string pertama
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
