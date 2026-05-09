import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/ecg_screen.dart';

void main() {
  runApp(const AppRafa());
}

class AppRafa extends StatelessWidget {
  const AppRafa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppRafa ECG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5A0),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const EcgScreen(),
    );
  }
}
