import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart'; // Sesuaikan path
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/register_screen.dart'; // Ganti dengan path yang sesuai
import 'package:rental_mobil_app_flutter/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart'; // Sesuaikan path

// Provider sederhana untuk loading state (bisa dibuat lebih canggih nanti)
final loginLoadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      final account = ref.read(appwriteAccountProvider);

      try {
        await account.deleteSession(sessionId: 'current');
      } catch (_) {}

      await account.createEmailPasswordSession(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
        );
      }
    } on AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Login gagal: ${e.message ?? "Error tidak diketahui"}')),
        );
      }
    } finally {
      if (mounted) {
        ref.read(loginLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginLoadingProvider);
    // Warna dari gambar Anda (estimasi)
    final Color backgroundColor =
        Color(0xFF1A2E1A); // Warna latar belakang gelap kehijauan
    final Color textFieldBackgroundColor =
        Color(0xFF2A402A); // Warna field input sedikit lebih terang
    final Color accentColor =
        Color(0xFF8BC34A); // Warna tombol login hijau muda
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color hintColor = Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Login',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Label Email
                Text(
                  'Email',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none, // Hilangkan border default
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Label Password
                Text(
                  'Password',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Aksi untuk "Forgot Password?"
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Forgot Password? (Not implemented)')),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: hintColor.withOpacity(0.8), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: accentColor))
                    : ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Login',
                            style: TextStyle(color: Colors.black87)),
                      ),
                const SizedBox(height: 20.0),
                // Tombol untuk ke halaman registrasi
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Belum punya akun? Registrasi di sini',
                    style: TextStyle(color: accentColor.withOpacity(0.9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
