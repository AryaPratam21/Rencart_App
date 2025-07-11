// lib/core/constants/app_constants.dart

class AppConstants {
  // --- ID PENGGUNA (GANTI DENGAN ID ANDA) ---
  // Anda bisa mendapatkan ini dari Appwrite Console > Auth > Users
  static const String ownerUserId = '683572290fde898e6279'; // Ganti dengan ID User Owner Anda

  // --- ID PROJECT APPWRITE ---
  // Anda bisa mendapatkan ini dari Appwrite Console > Project Settings
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1'; // Atau endpoint self-hosted Anda
  static const String appwriteProjectId = '68350fb100246925095e'; // Ganti dengan Project ID Anda

  // --- ID DATABASE & COLLECTION ---
  // Anda bisa mendapatkan ini dari Appwrite Console > Database
  static const String appwriteDatabaseId = '68356389002850d27576'; // Ganti dengan Database ID Anda
  static const String vehiclesCollectionId = '6835644f0004a0a373f8'; // Ganti jika nama collection Anda berbeda
  static const String bookingsCollectionId = '683566ce00237874d560'; // <-- Ganti dengan Collection ID asli dari Appwrite Console
  static const String paymentsCollectionId = '68356786000076101686'; // Ganti jika nama collection Anda berbeda
  // --- ID BUCKET STORAGE ---
  // Anda bisa mendapatkan ini dari Appwrite Console > Storage
  static const String vehicleImagesBucketId = '683e64aa002e6a85f935'; // Ganti jika nama bucket Anda berbeda
}