import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/seed_data.dart';

import 'providers/auth_provider.dart';
import 'providers/salon_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/booking/my_orders_screen.dart';
import 'screens/booking/booking_detail_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/support/about_screen.dart';
import 'screens/support/help_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await _initializeFirebase();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const GlozyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Inisialisasi Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set Firestore settings terlebih dahulu
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // MATIKAN App Check untuk sementara - ini menyebabkan error
      /*
      if (!kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.appAttest,
        );
      } else {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
      }
      */

      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
}

class GlozyApp extends StatelessWidget {
  const GlozyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SalonProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        title: 'Glozy',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        defaultTransition: Transition.cupertino,
        getPages: [
          // Admin routes
          GetPage(name: '/admin', page: () => const AdminScreen()),

          // Profile routes
          GetPage(name: '/profile', page: () => const ProfileScreen()),
          GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),

          // Booking routes
          GetPage(name: '/my-orders', page: () => const MyOrdersScreen()),
          GetPage(
              name: '/booking-detail',
              page: () {
                final args = Get.arguments;
                return BookingDetailScreen(booking: args);
              }),
          GetPage(
              name: '/booking-form',
              page: () {
                final args = Get.arguments as Map<String, dynamic>;
                return BookingFormScreen(
                  salon: args['salon'],
                  isHomeService: args['isHomeService'] ?? false,
                );
              }),

          // Support routes
          GetPage(name: '/about', page: () => const AboutScreen()),
          GetPage(name: '/help', page: () => const HelpScreen()),

          // Auth routes
          GetPage(name: '/login', page: () => const LoginScreen()),
        ],
      ),
    );
  }
}
