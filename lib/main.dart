import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'l10n/app_localizations.dart' show AppLocalizations;
import 'firebase_options.dart';
import 'constant.dart';
import 'homepage.dart';
import 'dart:async';

/// Main entry point of the application
/// Initializes all required services and configurations
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  /// --- UI Configuration ---
  // Configure system UI, orientation, and platform-specific styling
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }
  /// --- Environment Loading ---
  // Load environment variables from .env file
  await dotenv.load(fileName: "assets/.env");
  /// --- Firebase Initialization ---
  // Initialize Firebase services with platform-specific configuration
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  /// --- App Launch ---
  // Run the app with Riverpod provider scope
  runApp(const ProviderScope(child: MyApp()));
  /// --- Post-Launch Services ---
  // Activate Firebase App Check for security
  await FirebaseAppCheck.instance.activate(
    providerAndroid: androidProvider,
    providerApple: appleProvider,
  );
  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();
  // Initialize App Tracking Transparency
  await initATTPlugin();
}

/// Main application widget
/// Configures the MaterialApp with localization, theme, and navigation observers
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// --- Localization ---
      // Configure localization delegates and supported locales
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      /// --- App Configuration ---
      // App title and theme configuration
      title: 'LETS TOILET',
      theme: ThemeData(primarySwatch: Colors.grey),
      debugShowCheckedModeBanner: false,
      // Set HomePage as the initial route
      /// --- Routing ---
      home: const HomePage(),
      /// --- Navigation Observers ---
      // Configure navigation observers for analytics and route tracking
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        RouteObserver<ModalRoute>()
      ],
    );
  }
}

/// Initialize App Tracking Transparency (ATT) plugin
/// Requests tracking authorization on iOS/macOS platforms
Future<void> initATTPlugin() async {
  if (Platform.isIOS || Platform.isMacOS) {
    // Check current tracking authorization status
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    // Request authorization if not determined
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}