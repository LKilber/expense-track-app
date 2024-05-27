import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/screens/login_or_register_screen.dart';

class AuthScreen extends StatelessWidget {

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ExpenseTracker();
          }
          else {
            return LoginOrRegisterScreen();
          }
        }
      ),
    );
  }
}