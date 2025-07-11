// [KODE PERBAIKAN LENGKAP - KARTU OWNER]
// Ganti seluruh isi file owner_vehicle_card.dart dengan ini.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:intl/intl.dart';

import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'; // 2. Import provider service

// 3. Ubah menjadi ConsumerWidget
class OwnerVehicleCard extends ConsumerWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const OwnerVehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    required this.onEdit,
  });

  @override
  // 4. Tambahkan 'WidgetRef ref' pada build method
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onEdit, // Selalu ke halaman edit saat card ditekan
      child: Card(
        color: const Color(0xFF253825),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR MOBIL ---
              SizedBox(
                width: 100,
                height: 75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Builder(
                    builder: (context) {
                      final fileId = (vehicle.image_urls.isNotEmpty) ? vehicle.image_urls.first : null;
                      if (fileId != null && fileId.isNotEmpty) {
                        final previewUrl = ref.watch(vehicleServiceProvider).getFilePreviewUrl(fileId);
                        return Image.network(
                          previewUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 75,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.directions_car, color: Colors.grey, size: 40),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        );
                      } else {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.directions_car, color: Colors.grey, size: 40),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ... sisa info teks Anda (kode Anda sebelumnya sudah OK) ...
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama kendaraan
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${currencyFormatter.format(vehicle.rentalPricePerDay)}/hari',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Nopol
                    Text(
                      'Nopol: ${vehicle.plate_number.isNotEmpty ? vehicle.plate_number : '-'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Status dan Edit
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: vehicle.status == 'Tersedia' ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vehicle.status,
                            style: TextStyle(
                              color: vehicle.status == 'Tersedia' ? Colors.green.shade900 : Colors.red.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onEdit,
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

// ... helper widget _StatusChip tidak perlu diubah ...