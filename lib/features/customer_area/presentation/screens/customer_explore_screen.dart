import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/vehicle_providers.dart';
// Import halaman detail jika sudah ada dan ingin digunakan
// import 'customer_vehicle_detail_screen.dart';

// Enum dan Provider untuk tab navigasi bawah
enum ExplorePageTab { home, explore, booking }

final explorePageTabProvider = StateProvider<ExplorePageTab>(
    (ref) => ExplorePageTab.explore); // Default ke explore

class CustomerExploreScreen extends ConsumerWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(availableVehiclesProvider);
    final activeTab = ref.watch(explorePageTabProvider);

    const Color darkBackgroundColor = Color(0xFF1A2E1A);
    const Color appBarColor = Color(0xFF1A2E1A);
    const Color cardBackgroundColor = Color(0xFF253825);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color filterChipColor = Color(0xFF2F4F2F);
    const Color filterChipTextColor = Colors.white;
    const Color bottomNavBackgroundColor = Color(0xFF121F12);
    const Color bottomNavActiveColor = Colors.white;
    const Color bottomNavInactiveColor = Colors.white54;

    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$');

    Widget buildVehicleGrid() {
      return vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(
              child: Text('No cars available matching your criteria.',
                  style: TextStyle(color: secondaryTextColor, fontSize: 16),
                  textAlign: TextAlign.center),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
                16.0, 0, 16.0, 16.0), // Padding atas 0
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.70,
            ),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _CarCardExplore(
                // Menggunakan widget kartu yang berbeda namanya untuk kejelasan
                vehicle: vehicle,
                formatter: currencyFormatter,
                cardBackgroundColor: cardBackgroundColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                onTap: () {
                  print('Tapped on ${vehicle.name}');
                  if ((vehicle.id ?? '').isNotEmpty) {
                    // <-- perbaikan di sini
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => CustomerVehicleDetailScreen(vehicleId: vehicle.id!),
                    //   ),
                    // );
                  } else {
                    print("Error: Vehicle ID is empty or null.");
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: bottomNavActiveColor)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${err.toString()}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center),
          ),
        ),
      );
    }

    Widget buildPlaceholderPage(String title) {
      return Center(
        child: Text('$title Page - Placeholder',
            style: const TextStyle(fontSize: 18, color: primaryTextColor),
            textAlign: TextAlign.center),
      );
    }

    Widget currentPageContent;
    switch (activeTab) {
      case ExplorePageTab.explore:
        currentPageContent = buildVehicleGrid();
        break;
      case ExplorePageTab.home:
        // Kembali ke HomeScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
        currentPageContent = const SizedBox.shrink();
        break;
      case ExplorePageTab.booking:
        currentPageContent = buildPlaceholderPage("Booking");
        break;
    }

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Available cars',
            style: TextStyle(
                color: primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        backgroundColor: appBarColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 10.0),
            child: Row(
              children: [
                Expanded(
                    child: _FilterChipButtonExplore(
                        label: 'Location',
                        color: filterChipColor,
                        textColor: filterChipTextColor,
                        onTap: () => print("Location filter"))),
                const SizedBox(width: 10),
                Expanded(
                    child: _FilterChipButtonExplore(
                        label: 'Car type',
                        color: filterChipColor,
                        textColor: filterChipTextColor,
                        onTap: () => print("Car type filter"))),
                const SizedBox(width: 10),
                Expanded(
                    child: _FilterChipButtonExplore(
                        label: 'Price',
                        color: filterChipColor,
                        textColor: filterChipTextColor,
                        onTap: () => print("Price filter"))),
              ],
            ),
          ),
        ),
      ),
      body: currentPageContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeTab.index,
        onTap: (index) {
          ref.read(explorePageTabProvider.notifier).state =
              ExplorePageTab.values[index];
        },
        backgroundColor: bottomNavBackgroundColor,
        selectedItemColor: bottomNavActiveColor,
        unselectedItemColor: bottomNavInactiveColor,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_online), label: 'Booking'),
        ],
      ),
    );
  }
}

// Widget untuk kartu mobil (bisa diberi nama berbeda agar tidak konflik jika ada _CarCard lain)
class _CarCardExplore extends StatelessWidget {
  final Vehicle vehicle;
  final NumberFormat formatter;
  final VoidCallback onTap;
  final Color cardBackgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _CarCardExplore({
    required this.vehicle,
    required this.formatter,
    required this.onTap,
    required this.cardBackgroundColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: vehicle.imageUrls.isNotEmpty
                    ? Image.network(
                        vehicle.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey, size: 30)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white70)));
                        },
                      )
                    : Container(
                        color: Colors.black26,
                        child: const Icon(Icons.directions_car,
                            size: 40, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "${formatter.format(vehicle.rentalPricePerDay)}/day",
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk tombol filter (bisa diberi nama berbeda)
class _FilterChipButtonExplore extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _FilterChipButtonExplore({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4.0),
              Icon(Icons.keyboard_arrow_down, color: textColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension String jika belum ada di file utilitas global
// extension StringExtension on String {
//   String capitalize() {
//     if (isEmpty) return this;
//     return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
//   }
// }
