import 'package:driver_app/features/auth/view/pages/email_verified_wrapper.dart';
import 'package:driver_app/features/auth/view/pages/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    //  final AuthService authService = AuthService();
    final Logger logger = Logger();
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //Indicador de carga mientras se espera la conexion
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //El usuario esta autenticado?
          if (snapshot.hasData) {
            logger.i("User us autenticated ");
            return const EmailVerificationWrapper();
          } else {
            logger.i("User is not authenticated");
            return const SignInPage();
          }
        },
      ),
    );
  }
}
