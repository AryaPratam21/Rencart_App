import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart';
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/owner_area/presentation/screens/owner_booking_list_screen.dart';
import 'package:rental_mobil_app_flutter/features/reports_history/presentation/screens/owner_reports_screen.dart';
import 'package:rental_mobil_app_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/screens/owner_vehicle_list_screen.dart';

import '../../../auth/presentation/screens/welcome_screen.dart';

// --- Provider untuk data summary (NANTI AKAN DIAMBIL DARI APPWRITE) ---
// Untuk sekarang, kita buat provider dengan nilai statis agar UI bisa dibangun
final availableCarsProvider = Provider<int>((ref) => 5); // Contoh
final pendingBookingsProvider = Provider<int>((ref) => 2); // Contoh
final todaysBookingsProvider = Provider<int>((ref) => 1); // Contoh
// --------------------------------------------------------------------

// Provider untuk melacak index tab BottomNavigationBar yang aktif
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  // Fungsi logout
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final account = ref.read(appwriteAccountProvider);
      await account.deleteSession(sessionId: 'current');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal keluar: ${e.toString()}')),
        );
      }
    }
  }

  // Daftar halaman untuk BottomNavigationBar
  // Anda perlu membuat halaman-halaman ini. Untuk sekarang bisa placeholder.
  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboardContent(); // Dashboard dengan FeatureCard
      case 1:
        return OwnerVehicleListScreen();
      case 2:
        return OwnerBookingListScreen();
      case 3:
        return SettingsScreen();
      default:
        return Container();
    }
  }

  // Membangun konten utama dashboard (Summary & Features)
  Widget _buildDashboardContent() {
    // Ini adalah Consumer agar bisa watch provider di dalam fungsi build terpisah
    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);
        final availableCars = ref.watch(availableCarsProvider);
        final pendingBookings = ref.watch(pendingBookingsProvider);
        final todaysBookings = ref.watch(todaysBookingsProvider);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Mobil Tersedia',
                              value: availableCars.toString(),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Pesanan Menunggu',
                              value: pendingBookings.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      _SummaryCard(
                        title: "Pesanan Hari Ini",
                        value: todaysBookings.toString(),
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 32.0),
                      Text(
                        'Fitur',
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 16.0),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.9,
                        children: [
                          _FeatureCard(
                            title: 'Manajemen Mobil',
                            icon: Icons.directions_car_filled,
                            onTap: () {
                              ref.read(bottomNavIndexProvider.notifier).state = 1;
                            },
                          ),
                          _FeatureCard(
                            title: 'Manajemen Pesanan',
                            icon: Icons.calendar_month,
                            onTap: () {
                              ref.read(bottomNavIndexProvider.notifier).state = 2;
                            },
                          ),
                          _FeatureCard(
                            title: 'Laporan',
                            icon: Icons.bar_chart,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const OwnerReportsScreen(),
                                ),
                              );
                            },
                          ),
                          _FeatureCard(
                            title: 'Pengaturan',
                            icon: Icons.settings,
                            onTap: () {
                              ref.read(bottomNavIndexProvider.notifier).state = 3;
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    // Inisialisasi user otomatis jika null
    if (user == null && !isLoading) {
      Future.microtask(() async {
        await ref.read(authControllerProvider.notifier).getCurrentUser();
      });
    }
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final int currentIndex = ref.watch(bottomNavIndexProvider);
    final Color appBarColor =
        Color(0xFF121F12); // Warna AppBar lebih gelap sedikit
    final Color iconColor = Colors.white.withOpacity(0.8);

    return Scaffold(
      backgroundColor: Color(0xFF1A2E1A), // Warna latar belakang utama
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        automaticallyImplyLeading:
            currentIndex == 0, // <-- hanya Dashboard yang punya leading
        title: Text(
          currentIndex == 0
              ? 'Dasbor'
              : currentIndex == 1
                  ? 'Manajemen Mobil'
                  : currentIndex == 2
                      ? 'Pesanan'
                      : 'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: currentIndex == 0
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: iconColor),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            : null, // Tab lain tidak ada tombol back/menu
      ),
      drawer: currentIndex == 0 ? _buildDrawer(context, ref) : null,
      body: _getPageForIndex(currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Ikon aktif
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Mobil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        backgroundColor: appBarColor, // Warna latar belakang BottomNav
        selectedItemColor:
            Colors.white, // Warna item yang dipilih (putih lebih kontras)
        unselectedItemColor: Colors.white.withOpacity(0.6),
        showUnselectedLabels:
            false, // Sembunyikan label untuk item yang tidak dipilih agar lebih bersih
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Widget untuk Drawer
  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Color(0xFF1A2E1A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF121F12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Rental Mobil App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pemilik Dashboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, ref, Icons.dashboard, 'Dasbor', 0),
          _buildDrawerItem(
              context, ref, Icons.directions_car, 'Manajemen Mobil', 1),
          _buildDrawerItem(
              context, ref, Icons.calendar_today, 'Manajemen Pesanan', 2),
          _buildDrawerItem(context, ref, Icons.settings, 'Pengaturan', 3),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white.withOpacity(0.7)),
            title: Text('Keluar',
                style: TextStyle(color: Colors.white.withOpacity(0.9))),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat item Drawer
  Widget _buildDrawerItem(BuildContext context, WidgetRef ref, IconData icon,
      String title, int pageIndex,
      [VoidCallback? customOnTap]) {
    final Color drawerTextColor = Colors.white.withOpacity(0.9);
    final Color drawerIconColor = Colors.white.withOpacity(0.7);
    final bool isSelected = ref.watch(bottomNavIndexProvider) == pageIndex;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : drawerIconColor),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? Colors.white : drawerTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      onTap: customOnTap ??
          () {
            Navigator.pop(context); // Tutup drawer
            if (pageIndex != -1) {
              // -1 untuk navigasi ke halaman yang bukan bagian dari BottomNav
              ref.read(bottomNavIndexProvider.notifier).state = pageIndex;
            }
          },
    );
  }
}

// Widget Kustom untuk Kartu Summary (Sama seperti sebelumnya, mungkin dengan penyesuaian warna)
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isFullWidth;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color cardBackgroundColor = Color(0xFF2A402A); // Warna kartu
    final Color titleColor = Colors.white.withOpacity(0.7);
    final Color valueColor = Colors.white;

    return Card(
      color: cardBackgroundColor,
      elevation: 0, // Desain flat
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: isFullWidth
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Kustom untuk Kartu Fitur (Sama seperti sebelumnya, mungkin dengan penyesuaian warna)
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color cardBackgroundColor = Color(0xFF2A402A);
    final Color iconColor = Colors.white.withOpacity(0.9); // Warna ikon fitur
    final Color titleColor = Colors.white;

    return Card(
      color: cardBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // lebih kecil
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 28.0, color: iconColor), // lebih kecil
              const SizedBox(height: 8.0),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: titleColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
