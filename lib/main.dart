import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Web/Desktop Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB3W_ENcxQSxyssx4_ekib8JV6asD50ges",
        authDomain: "studentmanager-ba764.firebaseapp.com",
        projectId: "studentmanager-ba764",
        storageBucket: "studentmanager-ba764.firebasestorage.app",
        messagingSenderId: "8221670999",
        appId: "1:8221670999:web:1da2458910b256a06a2d12",
      ),
    );
    if (kDebugMode) print("💻 Firebase initialized for Web/Desktop");
  } else {
    // Mobile Firebase initialization
    await Firebase.initializeApp();
    if (kDebugMode) print("📱 Firebase initialized for Mobile");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().userChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Manager',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    // If user is logged in, show HomeScreen; else LoginScreen
    return user == null ? const LoginScreen() : const HomeScreen();
  }
}
