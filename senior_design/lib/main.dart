import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/SplashScreen.dart';
import 'utils/user_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user != null) {
      // Kullanıcı giriş yapmışsa, UserManager'da kullanıcı ID'sini güncelle
      UserManager.login(user.uid);
    } else {
      // Kullanıcı çıkış yapmışsa veya oturum kapatılmışsa, UserManager'da ID'yi temizle
      UserManager.logout();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
