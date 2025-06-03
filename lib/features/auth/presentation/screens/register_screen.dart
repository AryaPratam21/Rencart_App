import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart'; // Untuk AppwriteException dan ID.unique()
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart'; // Sesuaikan path
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/login_screen.dart'; // Sesuaikan path

// Provider sederhana untuk loading state (bisa dibuat lebih canggih nanti)
final registerLoadingProvider = StateProvider<bool>((ref) => false);

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      ref.read(registerLoadingProvider.notifier).state = true;
      try {
        final account = ref.read(appwriteAccountProvider);
        await account.create(
          userId: ID.unique(), // Appwrite akan generate ID unik
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
        );

        // Opsional: Set User Attribute 'role' setelah registrasi jika diperlukan.
        // Ini biasanya dilakukan oleh admin atau via Cloud Function setelah verifikasi.
        // Untuk pemilik tunggal, Anda bisa set manual di Appwrite Console untuk akun Anda.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigasi ke LoginScreen setelah registrasi berhasil
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } on AppwriteException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Registrasi gagal. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          ref.read(registerLoadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registerLoadingProvider);
    // Warna dari gambar Anda (estimasi, sama dengan login)
    final Color backgroundColor = Color(0xFF1A2E1A);
    final Color textFieldBackgroundColor = Color(0xFF2A402A);
    final Color accentColor = Color(0xFF50C878); // Sedikit beda untuk tombol register (hijau emerald)
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color hintColor = Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            // Kembali ke halaman login jika dari sana, atau sesuai navigasi sebelumnya
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Jika tidak ada halaman untuk di-pop (misal, ini halaman awal),
              // navigasi ke login sebagai default
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        title: Text(
          'Register',
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
                // Label Name
                Text(
                  'Name',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: hintColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Label Email
                Text(
                  'Email',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
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
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                const SizedBox(height: 32.0),
                isLoading
                    ? Center(child: CircularProgressIndicator(color: accentColor))
                    : ElevatedButton(
                        onPressed: _registerUser,
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
                        child: Text('Register', style: TextStyle(color: Colors.white)), // Teks putih di tombol hijau
                      ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: hintColor.withOpacity(0.8)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: accentColor, // Warna hijau untuk link Log in
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}