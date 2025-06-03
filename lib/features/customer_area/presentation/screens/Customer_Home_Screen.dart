import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/welcome_screen.dart'; // <-- Tambahkan import ini
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/vehicle_providers.dart';
import 'customer_booking_form_screen.dart';
import 'customer_explore_screen.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(availableVehiclesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Rent a car',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
            tooltip: 'Logout',
            onPressed: () async {
              // TODO: Tambahkan proses logout session/token jika ada
              // Navigasi ke WelcomeScreen dan hapus semua route sebelumnya
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Rent a car',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF253825),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Featured cars',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red))),
              data: (vehicles) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _FeaturedCarCard(vehicle: vehicle);
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Promotions',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF253825),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1461632830798-3adb3034e4c8?auto=format&fit=crop&w=600&q=80',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekend Getaway',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enjoy 20% off on all rentals this weekend.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8BC34A),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {},
                          child: const Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Browse by category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: const [
              _CategoryCard(
                label: 'Sedans',
                image: 'https://img.icons8.com/ios-filled/50/ffffff/sedan.png',
              ),
              _CategoryCard(
                label: 'SUVs',
                image: 'https://img.icons8.com/ios-filled/50/ffffff/suv.png',
              ),
              _CategoryCard(
                label: 'Sports Cars',
                image:
                    'https://img.icons8.com/ios-filled/50/ffffff/sports-car.png',
              ),
              _CategoryCard(
                label: 'Luxury Cars',
                image:
                    'https://img.icons8.com/ios-filled/50/ffffff/limousine.png',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121F12),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerExploreScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Booking'), // Ganti icon dan label
        ],
      ),
    );
  }
}

class _FeaturedCarCard extends StatelessWidget {
  final Vehicle vehicle;

  const _FeaturedCarCard({
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerBookingFormScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF203020),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                vehicle.imageUrls.isNotEmpty ? vehicle.imageUrls.first : '',
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                vehicle.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '\$${vehicle.rentalPricePerDay}/day',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String image;

  const _CategoryCard({
    required this.label,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF253825),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(image, width: 28, height: 28, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
