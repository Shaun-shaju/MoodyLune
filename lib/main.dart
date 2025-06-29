import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moodylune/widgets/splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // SplashMaster.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodyLune',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF021526),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF210F37),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.deliusSwashCapsTextTheme(
          const TextTheme(
            bodyLarge: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            bodyMedium: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            titleLarge: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
