import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';

/// Provider untuk mengambil detail user yang sedang login
final currentUserDetailProvider = FutureProvider<models.User?>((ref) async {
  final authState = ref.watch(authControllerProvider);
  return authState.user;
});
