import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        // Cek session user
        final user = await ref.read(authControllerProvider.notifier).getCurrentUser();
        if (user != null && user.$id != 'guest') {
          // Jika user valid, arahkan ke home utama
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Jika user null atau guest, ke welcome/login
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
