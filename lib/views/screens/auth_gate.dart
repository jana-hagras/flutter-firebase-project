import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/views/screens/firestore_screen.dart';
import 'package:notes_app/theme/app_theme.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // If Firebase apps list is empty, Firebase failed to init — skip auth.
    if (Firebase.apps.isEmpty) {
      return const FirestoreDemoScreen();
    }

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Firebase Auth error — fallback to home screen directly
            return const FirestoreDemoScreen();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) {
            return Theme(
              data: AppTheme.buildTheme(isDark: true, accent: Colors.blue),
              child: SignInScreen(
                providers: [EmailAuthProvider()],
                headerBuilder: (context, constraints, shrinkOffset) {
                  return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/app_icon.png'));
                },
                subtitleBuilder: (context, action) {
                  return Padding(
                      padding: const EdgeInsets.all(10),
                      child: action == AuthAction.signIn
                          ? const Text('Please sign in to our app')
                          : const Text('Register'));
                },
                footerBuilder: (context, action) {
                  return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                          'By signing in, you agree to our terms and conditions'));
                },
              ),
            );
          }
          return const FirestoreDemoScreen();
        });
  }
}
