import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 240, 240, 240),
  brightness: Brightness.light,
);

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const GroceryStore());
}

class GroceryStore extends StatelessWidget {
  const GroceryStore({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Store',
      theme: ThemeData().copyWith(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          headlineLarge: GoogleFonts.poppins().copyWith(
            fontSize: 32.0,
            fontWeight: FontWeight.w900,
            color: Colors.black
          ),
          headlineMedium: GoogleFonts.poppins().copyWith(
            fontSize: 28.0,
            fontWeight: FontWeight.w900,
            color: Colors.black
          ),
          titleLarge: GoogleFonts.poppins().copyWith(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          titleMedium: GoogleFonts.poppins().copyWith(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}