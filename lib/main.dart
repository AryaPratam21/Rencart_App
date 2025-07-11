import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/SplashScreen.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/customer/screens/customer_login_screen.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/customer/screens/customer_register_screen.dart';
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/Customer_Home_Screen.dart';
import 'package:rental_mobil_app_flutter/features/auth/presentation/screens/welcome_screen.dart';

// Function to request photo permission
Future<bool> requestPhotoPermission() async {
  try {
    // Check if permission is already granted
    final status = await Permission.photos.status;

    if (status.isGranted) {
      debugPrint('Photo permission already granted');
      return true;
    }

    // Request permission
    final result = await Permission.photos.request();

    if (result.isGranted) {
      debugPrint('Photo permission granted');
      return true;
    } else if (result.isDenied) {
      debugPrint('Photo permission denied');
      return false;
    } else if (result.isPermanentlyDenied) {
      debugPrint('Photo permission permanently denied');
      return false;
    }

    return false;
  } catch (e) {
    debugPrint('Error requesting photo permission: $e');
    return false;
  }
}

// Function to request location permission
Future<void> checkLocationPermission() async {
  try {
    final status = await Permission.location.request();

    if (!status.isGranted) {
      debugPrint('Location permission not granted');
    }
  } catch (e) {
    debugPrint('Error requesting location permission: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi Appwrite
  final client = appwrite.Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('68350fb100246925095e');

  await client.setSelfSigned();

  // Inisialisasi Appwrite SDK
  final account = appwrite.Account(client);
  final storage = appwrite.Storage(client);

  // Check and request permissions
  try {
    // Check storage permission status
    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    // Check camera permission status
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    // Check location permission status
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
  } catch (e) {
    debugPrint('Error handling permissions: $e');
  }

  runApp(
    ProviderScope(
      child: MyApp(account: account, storage: storage),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final appwrite.Account account;
  final appwrite.Storage storage;

  const MyApp({super.key, required this.account, required this.storage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RentCar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/customer-login': (context) => const CustomerLoginScreen(),
        '/customer-register': (context) => const CustomerRegisterScreen(),
        '/customer/home': (context) => const CustomerHomeScreen(),
        // Jangan tambahkan route ke dashboard langsung!
      },
    );
  }
}
