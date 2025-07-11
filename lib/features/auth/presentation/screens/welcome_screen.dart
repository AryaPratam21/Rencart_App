import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/customer/screens/customer_login_screen.dart'; // Ini untuk CustomerLoginScreen


class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Warna sesuai gambar
    const Color backgroundColor = Color(0xFF1A2E1A); // Hijau gelap utama
    const Color ownerButtonColor =
        Color(0xFF76B947); // Hijau terang untuk tombol Owner
    const Color customerButtonColor =
        Color(0xFF2A402A); // Hijau lebih gelap untuk tombol Customer
    const Color buttonTextColor = Colors.white;
    const Color termsTextColor = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // SafeArea untuk menghindari notch/status bar
        child: Column(
          children: [
            // Bagian Gambar Atas
            Container(
  height: screenHeight * 0.28,
  width: double.infinity,
  alignment: Alignment.center,
  child: Image.asset(
    'assets/Logo_Rencar.png',
    height: screenHeight * 0.28,
    fit: BoxFit.contain,
  ),
),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08), // Padding horizontal
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Pusatkan tombol secara vertikal
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ownerButtonColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 18), // Padding tombol
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen()), // Arahkan ke Login Owner
                          );
                        },
                        child: const Text('Masuk sebagai Pemilik',
                            style: TextStyle(color: Colors.white)),

                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customerButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerLoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Masuk sebagai Penyewa',
                            style: TextStyle(color: buttonTextColor)),

                      ),
                    ),
                    const Spacer(), // Mendorong teks TOS ke bawah
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              color: termsTextColor.withOpacity(0.6),
                              fontSize: 12),
                          children: <TextSpan>[
                            const TextSpan(
                                text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Terms of Service tapped');
                                  // TODO: Navigasi ke halaman Terms of Service
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Privacy Policy tapped');
                                  // TODO: Navigasi ke halaman Privacy Policy
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
