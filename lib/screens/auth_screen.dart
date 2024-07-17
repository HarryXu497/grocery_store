import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grocery_store/screens/navigation_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: dotenv.env["WEB_ID"]!),
            ],
            subtitleBuilder: (context, action) {
              return action == AuthAction.signIn
                  ? const Text("Welcome to Grocery Store™, please sign in.")
                  : const Text("Welcome to Grocery Store™, please sign up.");
            },
            sideBuilder: (context, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Text("Side"),
                ),
              );
            },
          );
        }

        return const NavigationScreen();
      },
    );
  }
}
