import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/owner_area/presentation/screens/owner_booking_list_screen.dart';
import 'package:rental_mobil_app_flutter/features/reports_history/presentation/screens/owner_reports_screen.dart';
import 'package:rental_mobil_app_flutter/features/settings/presentation/screens/settings_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/screens/owner_vehicle_list_screen.dart';

import '../../../auth/presentation/screens/login_screen.dart'; // Untuk logout

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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout gagal: ${e.toString()}')),
        );
      }
    }
  }

  // Daftar halaman untuk BottomNavigationBar
  // Anda perlu membuat halaman-halaman ini. Untuk sekarang bisa placeholder.
  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0: // Home/Dashboard
        return _buildDashboardContent(); // Konten summary & features dashboard

      case 1: // Cars (Car Management)
        return const OwnerVehicleListScreen();

      case 2: // Bookings
        return const OwnerBookingListScreen();

      case 3: // Profile/Settings
        return const SettingsScreen(); // <-- UI SETTINGS ANDA

      default:
        return _buildDashboardContent(); // Default ke konten dashboard
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
              Text(
                'Summary',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Available Cars',
                      value: availableCars.toString(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pending Bookings',
                      value: pendingBookings.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _SummaryCard(
                title: "Today's Bookings",
                value: todaysBookings.toString(),
                isFullWidth: true,
              ),
              const SizedBox(height: 32.0),
              Text(
                'Features',
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
                childAspectRatio: 1.9,
                children: [
                  _FeatureCard(
                    title: 'Car Management',
                    icon: Icons.directions_car_filled,
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 1;
                    },
                  ),
                  _FeatureCard(
                    title: 'Booking Management',
                    icon: Icons.calendar_month,
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 3;
                    },
                  ),
                  _FeatureCard(
                    title: 'Reports',
                    icon: Icons.bar_chart,
                    onTap: () {
                      // Navigasi ke halaman laporan
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OwnerReportsScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureCard(
                    title: 'Settings',
                    icon: Icons.settings,
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 4;
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);
    final Color appBarColor =
        Color(0xFF121F12); // Warna AppBar lebih gelap sedikit
    final Color iconColor = Colors.white.withOpacity(0.8);

    return Scaffold(
      backgroundColor: Color(0xFF1A2E1A), // Warna latar belakang utama
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: Text(
          currentIndex == 0
              ? 'Dashboard'
              : currentIndex == 1
                  ? 'Car Management'
                  : currentIndex == 2
                      ? 'Add New'
                      : currentIndex == 3
                          ? 'Bookings'
                          : 'Profile',
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
            : null,
        // Hapus atau kosongkan actions:
        // actions: [],
      ),
      drawer: currentIndex == 0 ? _buildDrawer(context, ref) : null,
      body: _getPageForIndex(
          currentIndex), // Menampilkan halaman sesuai tab yang dipilih
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
            label: 'Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
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
    final Color drawerHeaderColor = Color(0xFF121F12);
    final Color drawerTextColor = Colors.white.withOpacity(0.9);
    final Color drawerIconColor = Colors.white.withOpacity(0.7);

    return Drawer(
      backgroundColor: Color(0xFF1A2E1A), // Warna latar belakang drawer
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: drawerHeaderColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Anda bisa menambahkan logo atau gambar di sini
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
                  'Pemilik Dashboard', // Subtitle atau email pemilik
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, ref, Icons.dashboard, 'Dashboard', 0),
          _buildDrawerItem(
              context, ref, Icons.directions_car, 'Car Management', 1),
          _buildDrawerItem(
              context, ref, Icons.calendar_today, 'Booking Management', 3),
          // Drawer item untuk Settings, buka halaman Settings tanpa mengubah tab
          _buildDrawerItem(
            context,
            ref,
            Icons.settings,
            'Settings',
            -1,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.logout, color: drawerIconColor),
            title: Text('Logout', style: TextStyle(color: drawerTextColor)),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 36.0, color: iconColor),
              const SizedBox(height: 12.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: titleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
