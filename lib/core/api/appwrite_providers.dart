// lib/core/api/appwrite_providers.dart (atau lokasi yang Anda pilih)
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';

// Provider untuk instance Client Appwrite
final appwriteClientProvider = Provider<Client>((ref) {
  Client client = Client();
  client
          .setEndpoint(AppConstants.appwriteEndpoint)
          .setProject(AppConstants.appwriteProjectId)
      // Untuk Appwrite Cloud, .setSelfSigned() biasanya tidak diperlukan atau bisa di-set false
      // Jika Anda menggunakan self-hosted dengan sertifikat self-signed untuk dev, gunakan:
      // .setSelfSigned(status: true);
      ; // Titik koma di sini setelah semua konfigurasi client
  return client;
});

// Provider untuk instance Account, bergantung pada appwriteClientProvider
final appwriteAccountProvider = Provider<Account>((ref) {
  // Mengambil instance Client dari appwriteClientProvider
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

// Provider untuk instance Databases (buat saat Anda membutuhkannya di Iterasi 2)
final appwriteDatabasesProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

// Provider untuk instance Teams (buat saat Anda membutuhkannya di Iterasi 2)
final appwriteTeamsProvider = Provider<Teams>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Teams(client);
});

// Provider untuk instance Storage (buat saat Anda membutuhkannya di Iterasi 2)
final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});
