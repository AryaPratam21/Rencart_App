import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal, tambahkan ke pubspec.yaml: intl: ^0.18.1 (atau terbaru)

// --- MODEL DATA DUMMY (Hanya untuk contoh UI ini) ---
class CarDetailVehicle {
  final String id;
  final String name;
  final String licensePlate;
  final String? vin;
  final int? mileage;
  final String location;
  String status; // Bisa diubah
  final List<String> imageUrls;
  final String? transmission;
  final int? capacity;
  final String? description;

  CarDetailVehicle({
    required this.id,
    required this.name,
    required this.licensePlate,
    this.vin,
    this.mileage,
    required this.location,
    required this.status,
    required this.imageUrls,
    this.transmission,
    this.capacity,
    this.description,
  });
}

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
final _selectedStatusProvider = StateProvider.family<String?, String>((ref, vehicleId) {
  // Nilai awal akan di-set saat data mobil dimuat
  return null;
});

// --- WIDGET UTAMA ---
class OwnerCarDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId; // ID mobil yang akan ditampilkan

  const OwnerCarDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<OwnerCarDetailScreen> createState() => _OwnerCarDetailScreenState();
}

class _OwnerCarDetailScreenState extends ConsumerState<OwnerCarDetailScreen> {
  // Data mobil dummy (GANTI DENGAN PROVIDER APPWRITE ANDA)
  CarDetailVehicle? _vehicle;
  List<CarDetailBooking> _bookingHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Simulasi pengambilan data
    await Future.delayed(const Duration(seconds: 1));
    if (widget.vehicleId == "car123_demo") {
      setState(() {
        _vehicle = CarDetailVehicle(
          id: "car123_demo",
          name: "2021 Toyota Camry",
          licensePlate: "ABC-1234",
          vin: "1234567890ABCDEFG",
          mileage: 35000,
          location: "123 Main St, Anytown",
          status: "available",
          imageUrls: ["https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg/1024px-2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg"],
          transmission: "Automatic",
          capacity: 5,
          description: "Mobil keluarga yang nyaman dan irit bahan bakar.",
        );
        _bookingHistory = [
          CarDetailBooking(customerName: "Ava Carter", startDate: DateTime(2024, 7, 15), endDate: DateTime(2024, 7, 20)),
          CarDetailBooking(customerName: "Ethan Harper", startDate: DateTime(2024, 6, 10), endDate: DateTime(2024, 6, 12)),
        ];
        // Inisialisasi provider status terpilih dengan status mobil saat ini
        // setelah data dimuat pertama kali
        ref.read(_selectedStatusProvider(widget.vehicleId).notifier).state = _vehicle?.status;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Car not found.";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges(String newStatus) async {
    if (_vehicle == null) return;

    setState(() {
      // Menampilkan loading di tombol atau UI lain jika perlu
    });

    print("Simulating saving status: $newStatus for vehicle ID: ${widget.vehicleId}");
    // Simulasi panggilan API
    await Future.delayed(const Duration(seconds: 1));

    // Jika sukses, update state lokal dan tampilkan pesan
    setState(() {
      _vehicle!.status = newStatus; // Update status di objek lokal
    });
    ref.read(_selectedStatusProvider(widget.vehicleId).notifier).state = newStatus; // Pastikan provider juga update

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully! (Simulated)')),
      );
    }
    // Di aplikasi nyata: Panggil Appwrite service untuk update, lalu refresh data dari Appwrite
    // ref.invalidate(demoVehicleDetailProvider(widget.vehicleId));
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? selectedStatus = ref.watch(_selectedStatusProvider(widget.vehicleId));

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(title: const Text('Car Details', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A2426), iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFB2D3A8))),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(title: const Text('Car Details', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A2426), iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
        body: Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 16))),
      );
    }

    if (_vehicle == null) {
      // Seharusnya tidak terjadi jika _errorMessage null dan _isLoading false, tapi sebagai fallback
      return Scaffold(
        backgroundColor: const Color(0xFF1F2C2E),
        appBar: AppBar(title: const Text('Car Details', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1A2426), iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
        body: const Center(child: Text("No car data available.", style: TextStyle(color: Colors.white70))),
      );
    }

    // Jika _vehicle tidak null, kita bisa aman mengaksesnya
    final car = _vehicle!;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2C2E),
      appBar: AppBar(
        title: const Text('Car Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A2426),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (car.imageUrls.isNotEmpty)
              Image.network(
                car.imageUrls.first,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFFB2D3A8))),
                  );
                },
              )
            else
              Container(
                height: 250,
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.directions_car, size: 100, color: Colors.grey)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('License Plate:', car.licensePlate),
                  if (car.vin != null) _buildDetailRow('VIN:', car.vin!),
                  if (car.mileage != null) _buildDetailRow('Mileage:', '${NumberFormat.decimalPattern().format(car.mileage)} miles'),
                  _buildDetailRow('Location:', car.location),
                  if (car.transmission != null) _buildDetailRow('Transmission:', car.transmission!),
                  if (car.capacity != null) _buildDetailRow('Capacity:', '${car.capacity} seats'),
                  if (car.description != null && car.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Description:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(car.description!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],

                  const SizedBox(height: 24),
                  Text(
                    'Status',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10.0,
                    children: ['available', 'rented', 'maintenance'].map((statusOption) { // Hanya 3 status seperti di gambar
                      final isSelected = selectedStatus == statusOption;
                      return ChoiceChip(
                        label: Text(statusOption.capitalize(), style: TextStyle(color: isSelected ? Colors.black87 : Colors.white70)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(_selectedStatusProvider(widget.vehicleId).notifier).state = statusOption;
                          }
                        },
                        selectedColor: const Color(0xFFB2D3A8),
                        backgroundColor: const Color(0xFF2A3A3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFB2D3A8) : const Color(0xFF4A5C5F),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Sesuaikan padding
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Booking History',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  if (_bookingHistory.isEmpty)
                    const Text('No booking history for this car.', style: TextStyle(color: Colors.white70))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bookingHistory.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFF2A3A3D), height: 1),
                      itemBuilder: (context, index) {
                        final booking = _bookingHistory[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: _getAvatarColor(booking.customerName), // Warna avatar acak sederhana
                            child: Text(
                              booking.customerName.isNotEmpty ? booking.customerName.substring(0,1).toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          title: Text(booking.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${DateFormat.yMMMd().format(booking.startDate)} - ${DateFormat.yMMMd().format(booking.endDate)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40), // Beri ruang lebih sebelum tombol
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB2D3A8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: (selectedStatus != null && selectedStatus != car.status)
              ? () {
                  _saveChanges(selectedStatus);
                }
              : null, // Disable tombol jika status tidak berubah
          child: const Text('Save Changes', style: TextStyle(color: Color(0xFF1F2C2E))),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 14)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

    final List<Color> _avatarColors = [ // Warna untuk avatar dummy
        Colors.blueGrey, Colors.teal, Colors.indigo, Colors.deepOrange, Colors.brown
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
