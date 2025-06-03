import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/login_screen.dart'; // Sesuaikan path
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_home_screen.dart'; // Sesuaikan path

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

    // URL Gambar Placeholder (ganti dengan aset Anda jika ada)
    const String topImageUrl =
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y2Fyc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=800&q=60'; // Contoh gambar mobil

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // SafeArea untuk menghindari notch/status bar
        child: Column(
          children: [
            // Bagian Gambar Atas
            Container(
              height: screenHeight * 0.45, // Sekitar 45% tinggi layar
              width: double.infinity,
              decoration: const BoxDecoration(
                // Anda bisa menggunakan Image.asset jika gambar ada di lokal
                image: DecorationImage(
                  image: NetworkImage(
                      topImageUrl), // Ganti dengan NetworkImage atau AssetImage
                  fit: BoxFit.cover,
                ),
                // Tambahkan gradient overlay jika ingin efek seperti di gambar
                // gradient: LinearGradient(
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   colors: [
                //     Colors.transparent,
                //     backgroundColor.withOpacity(0.3),
                //     backgroundColor.withOpacity(0.8),
                //     backgroundColor,
                //   ],
                //   stops: [0.0, 0.6, 0.8, 1.0],
                // ),
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
                        child: const Text('Login as Owner',
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CustomerHomeScreen()), // Langsung ke Customer Home
                          );
                        },
                        child: const Text('Login as Customer',
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
