import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/welcome_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_explore_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_my_bookings_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_vehicle_detail_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;
    

String getFilePreviewUrl(String fileId) {
  return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
}

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Home
    CustomerHomeContent(),
    // Explore
    CustomerExploreScreen(),
    // Booking
    CustomerBookingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sewa Mobil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
            tooltip: 'Keluar',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121F12),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Jelajah'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Pesanan',
          ),
        ],
      ),
    );
  }
}

// Pisahkan konten Home agar tidak terjadi loop pada CustomerHomeScreen
class CustomerHomeContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(
      vehicle_providers.availableVehiclesProvider,
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vehicle_providers.availableVehiclesProvider);
      },
      child: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Terjadi Kesalahan: $e')),
        data: (vehicles) {
          // Filter hanya menampilkan mobil yang tersedia
          final availableVehicles = vehicles
              .where((v) => v.status == 'Tersedia')
              .toList();

          if (availableVehicles.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada mobil tersedia untuk disewa.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            itemCount: availableVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = availableVehicles[index];
              return _FeaturedCarCard(vehicle: vehicle);
            },
          );
        },
      ),
    );
  }
}

class _FeaturedCarCard extends ConsumerWidget {
  final Vehicle vehicle;

  const _FeaturedCarCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Pastikan vehicle id tidak null dan tidak kosong
          if (vehicle.id == null || vehicle.id!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data mobil tidak lengkap'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Navigasi ke halaman detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomerVehicleDetailScreen(vehicleId: vehicle.id!),
            ),
          ).then((_) {
            // Refresh data setelah kembali dari detail
            ref.invalidate(vehicle_providers.availableVehiclesProvider);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF253825),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: vehicle.image_urls.isNotEmpty
                          ? Image.network(
                              getFilePreviewUrl(vehicle.image_urls.first),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 80,
                                  color: Colors.grey[700],
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.white54,
                                    size: 30,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 100,
                                      height: 80,
                                      color: Colors.grey[700],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    );
                                  },
                            )
                          : Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[700],
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.white54,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  if (vehicle.status != 'Tersedia')
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: vehicle.status == 'on_rent'
                              ? Colors.red.withOpacity(0.9)
                              : Colors.orange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle.status == 'on_rent'
                              ? 'Disewa'
                              : 'Tidak Tersedia',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatter.format(vehicle.rentalPricePerDay),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            vehicle.currentLocationCity,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
