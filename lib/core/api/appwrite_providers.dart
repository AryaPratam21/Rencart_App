// lib/core/api/appwrite_providers.dart (atau lokasi yang Anda pilih)
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- PASTIKAN BAGIAN INI BENAR ---
const String appwriteEndpoint = 'https://cloud.appwrite.io/v1'; // Endpoint Appwrite Cloud Anda (biasanya ini) atau endpoint self-hosted
const String appwriteProjectId = '68350fb100246925095e'; // Project ID Anda dari Appwrite Console
// ---------------------------------

// Provider untuk instance Client Appwrite
final appwriteClientProvider = Provider<Client>((ref) {
  Client client = Client();
  client
    .setEndpoint(appwriteEndpoint)
    .setProject(appwriteProjectId)
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

// Provider untuk instance Storage (buat saat Anda membutuhkannya di Iterasi 2)
final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});