import 'package:appwrite/models.dart' as appwrite_models; // Untuk User model
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/core/api/appwrite_providers.dart'; // Untuk data user & logout
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/login_screen.dart'; // Untuk navigasi setelah logout
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart';

// Provider untuk state switch notifikasi (contoh)
final pushNotificationProvider =
    StateProvider<bool>((ref) => true); // Default true
final emailNotificationProvider =
    StateProvider<bool>((ref) => true); // Default true

// Provider untuk data user (jika belum ada secara global)
final currentUserDetailProvider =
    FutureProvider<appwrite_models.User?>((ref) async {
  final account = ref.watch(appwriteAccountProvider);
  try {
    return await account.get();
  } catch (e) {
    return null; // Handle error atau kembalikan null jika tidak ada user
  }
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Logout dari akun dan kembali ke LoginScreen
  Future<void> logout(BuildContext context, WidgetRef ref) async {
    try {
      final account = ref.read(appwriteAccountProvider);
      try {
        await account.deleteSession(sessionId: 'current');
        debugPrint('[Logout] Session deleted successfully.');
      } catch (e) {
        debugPrint('[Logout] Error deleting session: ${e.toString()}');
        // Tetap lanjutkan logout meski gagal hapus session
      }
      // Invalidate semua provider penting!
      ref.invalidate(currentUserDetailProvider);
      ref.invalidate(customerBookingsProvider);
      ref.invalidate(availableVehiclesProvider);
      // Tambahkan provider lain jika ada yang menyimpan data user/booking
      ref.invalidate(bookingDetailProvider);
      ref.invalidate(ownerBookingsProvider);
      // Jika ada provider lain, tambahkan di sini
      debugPrint('[Logout] Semua provider penting di-invalidate.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('[Logout] ERROR: ${e.toString()}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout gagal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color cardColor = Color(0xFF2A402A);
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color subTextColor = Colors.white.withOpacity(0.7);
    final Color accentColor = Color(0xFF8BC34A);

    final isPushEnabled = ref.watch(pushNotificationProvider);
    final isEmailEnabled = ref.watch(emailNotificationProvider);
    final currentUserAsyncValue = ref.watch(currentUserDetailProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        _buildSectionTitle('Payment', textColor),
        _buildSettingsItem(
          context: context,
          icon: Icons.account_balance,
          iconBackgroundColor: cardColor,
          iconColor: accentColor,
          title: 'Bank account',
          subtitle: 'Bank of America',
          trailing:
              Icon(Icons.arrow_forward_ios, size: 18, color: subTextColor),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Bank Account Detail (Not Implemented)')),
            );
          },
        ),
        const SizedBox(height: 24.0),
        _buildSectionTitle('Notifications', textColor),
        _buildSwitchItem(
          context: context,
          icon: Icons.notifications_active_outlined,
          iconBackgroundColor: cardColor,
          iconColor: accentColor,
          title: 'Push notifications',
          subtitle:
              'Receive notifications for new bookings, cancellations, and other',
          value: isPushEnabled,
          onChanged: (bool value) {
            ref.read(pushNotificationProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 12.0),
        _buildSwitchItem(
          context: context,
          icon: Icons.email_outlined,
          iconBackgroundColor: cardColor,
          iconColor: accentColor,
          title: 'Email notifications',
          subtitle:
              'Receive email notifications for new bookings, cancellations, and other',
          value: isEmailEnabled,
          onChanged: (bool value) {
            ref.read(emailNotificationProvider.notifier).state = value;
          },
        ),
        const SizedBox(height: 32.0),
        _buildSectionTitle('Account', textColor),
        currentUserAsyncValue.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            return Column(
              children: [
                _buildSettingsItem(
                    context: context,
                    icon: Icons.person_outline,
                    iconBackgroundColor: cardColor,
                    iconColor: accentColor,
                    title: user.name.isNotEmpty ? user.name : 'User Profile',
                    subtitle: user.email,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Edit Profile (Not Implemented)')),
                      );
                    }),
                const SizedBox(height: 12.0),
                _buildSettingsItem(
                    context: context,
                    icon: Icons.lock_outline,
                    iconBackgroundColor: cardColor,
                    iconColor: accentColor,
                    title: 'Change Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Change Password (Not Implemented)')),
                      );
                    }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading user: $err',
              style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(height: 24.0),

      ],
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor.withOpacity(0.85),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final Color itemBackgroundColor =
        Color(0xFF2A402A); // Sedikit lebih terang dari background utama
    final Color titleTextColor = Colors.white.withOpacity(0.9);
    final Color subtitleTextColor = Colors.white.withOpacity(0.6);

    return Material(
      // Bungkus dengan Material agar InkWell punya efek ripple
      color: itemBackgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor, // Bisa sama dengan itemBackgroundColor atau berbeda
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleTextColor),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style:
                            TextStyle(fontSize: 13, color: subtitleTextColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingsItem(
      context: context,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF8BC34A), // Warna switch aktif
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[600]?.withOpacity(0.5),
      ),
      onTap: () => onChanged(
          !value), // Agar seluruh baris bisa di-tap untuk toggle switch
    );
  }
}
