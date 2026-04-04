import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/services/notification_service.dart';
import 'package:notes_app/views/screens/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("Firebase initialized successfully!");

    // Initialize FCM Service
    await SimpleFCMService().init();
    
  } catch (e) {
    debugPrint(
        "Firebase init failed or already initialized. Safe to continue offline.");
  }

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // REQUIRED for notification navigation to work
      debugShowCheckedModeBanner: false,
      title: 'My WorkSpace',
      themeMode: ThemeMode.dark,
      theme: AppTheme.buildTheme(isDark: false, accent: Colors.cyan),
      darkTheme: AppTheme.buildTheme(isDark: true, accent: Colors.cyan),
      home: const AuthGate(),
    );
  }
}
