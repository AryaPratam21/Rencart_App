import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/screens/add_vehicle_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/screens/edit_vehicle_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/widgets/owner_vehicle_card.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart';

class OwnerVehicleListScreen extends ConsumerStatefulWidget {
  const OwnerVehicleListScreen({super.key});

  @override
  ConsumerState<OwnerVehicleListScreen> createState() =>
      _OwnerVehicleListScreenState();
}

class _OwnerVehicleListScreenState
    extends ConsumerState<OwnerVehicleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final refreshResult = await ref.refresh(ownerVehiclesProvider);
      debugPrint('Refresh result: $refreshResult');
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color fabColor = Color(0xFF8BC34A);
    final vehiclesAsync = ref.watch(ownerVehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Mobil'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: RefreshIndicator(
        onRefresh: () async {
          final refreshResult = await ref.refresh(ownerVehiclesProvider);
          debugPrint('Refresh result: $refreshResult');
          return;
        },
        child: vehiclesAsync.when(
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada mobil yang ditambahkan',
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan mobil baru untuk mulai menyewakan',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (vehicles.isNotEmpty) ...[
                  Text(
                    'Mobil Tersedia',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...vehicles
                      .where((vehicle) => vehicle.status == 'Tersedia')
                      .map((vehicle) {
                        return OwnerVehicleCard(
                          vehicle: vehicle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVehicleScreen(vehicle: vehicle),
                              ),
                            ).then((isSuccess) {
                              if (isSuccess == true) {
                                ref.invalidate(ownerVehiclesProvider);
                              }
                            });
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVehicleScreen(vehicle: vehicle),
                              ),
                            ).then((isSuccess) {
                              if (isSuccess == true) {
                                ref.invalidate(ownerVehiclesProvider);
                              }
                            });
                          },
                        );
                      })
                      .toList(),

                  const SizedBox(height: 24),
                  Text(
                    'Mobil Tidak Tersedia',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...vehicles
                      .where((vehicle) => vehicle.status != 'Tersedia')
                      .map((vehicle) {
                        return OwnerVehicleCard(
                          vehicle: vehicle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVehicleScreen(vehicle: vehicle),
                              ),
                            ).then((isSuccess) {
                              if (isSuccess == true) {
                                ref.invalidate(ownerVehiclesProvider);
                              }
                            });
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVehicleScreen(vehicle: vehicle),
                              ),
                            ).then((isSuccess) {
                              if (isSuccess == true) {
                                ref.invalidate(ownerVehiclesProvider);
                              }
                            });
                          },
                        );
                      })
                      .toList(),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${error.toString()}',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(ownerVehiclesProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: fabColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVehicleScreen(
              ),
            ),
          ).then((isSuccess) {
            if (isSuccess == true) {
              ref.invalidate(ownerVehiclesProvider);
            }
          });
        },
      ),
    );
  }
}
