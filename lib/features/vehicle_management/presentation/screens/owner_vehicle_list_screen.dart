import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/screens/add_edit_vehicle_screen.dart';

class OwnerVehicleListScreen extends ConsumerWidget {
  const OwnerVehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsyncValue = ref.watch(ownerVehiclesProvider);
    final Color backgroundColor = Color(0xFF1A2E1A);
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color fabColor = Color(0xFF8BC34A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text('My Cars',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: vehiclesAsyncValue.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                // Menggunakan Column untuk menata teks dan mungkin ikon
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_transfer_rounded,
                      size: 60,
                      color: textColor.withOpacity(0.5)), // Contoh ikon
                  const SizedBox(height: 16),
                  Text(
                    'No cars added yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor.withOpacity(0.7), fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the "+" button below to add your first car.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final availableVehicles = vehicles
              .where((v) => v.status.toLowerCase() == 'available')
              .toList();
          final unavailableVehicles = vehicles
              .where((v) => v.status.toLowerCase() != 'available')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                16.0, 16.0, 16.0, 80.0), // Tambah padding bawah untuk FAB
            children: [
              if (availableVehicles.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Available Cars',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                ...availableVehicles
                    .map((vehicle) => VehicleListItemWidget(vehicle: vehicle))
                    .toList(),
                if (unavailableVehicles.isNotEmpty)
                  const SizedBox(
                      height: 24.0), // Jarak jika ada mobil tidak tersedia
              ],
              if (unavailableVehicles.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Unavailable Cars',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                ...unavailableVehicles
                    .map((vehicle) => VehicleListItemWidget(vehicle: vehicle))
                    .toList(),
              ],
              if (availableVehicles.isEmpty && unavailableVehicles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'No available cars at the moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor.withOpacity(0.7), fontSize: 16),
                  ),
                ),
            ],
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: fabColor)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading cars: ${error.toString()}.\nPlease check your internet connection or try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditVehicleScreen(
                    isEditMode: false, vehicle: null)), // Kirim vehicle: null
          );
        },
        backgroundColor: fabColor,
        icon: const Icon(Icons.add, color: Colors.black87),
        label: const Text('Add New Car',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- KODE UNTUK VehicleListItemWidget (SEPERTI YANG SUDAH ANDA BUAT) ---
class VehicleListItemWidget extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleListItemWidget({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color subTextColor = Colors.white.withOpacity(0.7);
    final Color priceColor = Colors.white;

    return Card(
      color: Color(0xFF2A402A),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEditVehicleScreen(isEditMode: true, vehicle: vehicle),
            ),
          );
          print('Tapped on ${vehicle.name}');
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: vehicle.imageUrls.isNotEmpty
                    ? Image.network(
                        vehicle.imageUrls.first,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 60,
                            color: Colors.grey[700],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[400])),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 60,
                            color: Colors.grey[800],
                            child: Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Color(0xFF8BC34A),
                            )),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 60,
                        color: Colors.grey[700],
                        child: Icon(Icons.no_photography,
                            color: Colors.grey[400])),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Plate: ${vehicle.plateNumber}, Status: ${vehicle.status}', // Menambahkan 'Status:'
                      style: TextStyle(fontSize: 13, color: subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '\$${vehicle.rentalPricePerDay.toStringAsFixed(0)}/day',
                style: TextStyle(
                    fontSize: 15,
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

// Provider harus FutureProvider agar bisa pakai .when di UI
final ownerVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final client = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('68350fb100246925095e');
  final database = appwrite.Databases(client);

  final response = await database.listDocuments(
    databaseId: '68356389002850d27576',
    collectionId: '6835644f0004a0a373f8',
  );

  // Mapping dari response ke List<Vehicle>
  return response.documents
      .map((doc) => Vehicle(
            id: doc.$id, // <-- Tambahkan baris ini!
            name: doc.data['name'] ?? '',
            plateNumber: doc.data['plateNumber'] ?? '',
            status: doc.data['status'] ?? '',
            rentalPricePerDay: doc.data['rentalPricePerDay'] ?? 0,
            imageUrls: List<String>.from(doc.data['imageUrls'] ?? []),
            currentLocationCity: doc.data['currentLocationCity'] ?? '',
            // ...field lain
          ))
      .toList();
});
