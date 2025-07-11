import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = Provider<Client>((ref) {
  final client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('68350fb100246925095e')
    ..setSelfSigned(status: true); // For development
  return client;
});

final databasesProvider = Provider<Databases>((ref) {
  return Databases(ref.watch(clientProvider));
});

final storageProvider = Provider<Storage>((ref) {
  return Storage(ref.watch(clientProvider));
});
