import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart';

class AuthState {
  final String? token;
  final models.User? user;
  final bool isLoading;

  AuthState({this.token, this.user, this.isLoading = false});

  AuthState copyWith({String? token, models.User? user, bool? isLoading}) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Account _account;

  AuthController(this._account) : super(AuthState());

  /// Register user baru
  Future<void> register(String email, String password, String name) async {
    // Hapus session guest sebelum register
    try { await _account.deleteSession(sessionId: 'current'); } catch (_) {}
    final newUser = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    print('[AUTH] User registered: id=${newUser.$id}, email=${newUser.email}');
    // Setelah register, langsung login user
    await login(email, password);
  }

  /// Login user
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      // Hapus session guest sebelum login
      try { await _account.deleteSession(sessionId: 'current'); } catch (_) {}
      // Login user
      await _account.createEmailPasswordSession(email: email, password: password);
      final user = await _account.get();
      print('[AUTH] User after login: id=${user.$id}, email=${user.email}');
      if (user.$id == 'guest') {
        print('[AUTH][WARNING] User is still guest after login! Force logout.');
        await logout();
        throw Exception('Login gagal: Anda masih dianggap guest. Silakan coba lagi.');
      }
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      state = state.copyWith(token: null, user: null);
    } catch (_) {
      // Abaikan error jika tidak ada session
    }
  }

  /// Mendapatkan user yang sedang login
  Future<models.User?> getCurrentUser() async {
    if (state.user != null) {
      return state.user;
    }
    try {
      // Jika user null, coba ambil dari server
      final user = await _account.get();
      // Update state dengan user info
      state = state.copyWith(user: user);
      return user;
    } catch (e) {
      // Jika gagal, kembalikan null
      return null;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final account = ref.watch(appwriteAccountProvider);
    return AuthController(account);
  },
);
