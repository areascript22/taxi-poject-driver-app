import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthService {
  // Login with email and password
  static Future<User?> loginWithEmailAndPassword(
      String email, String password) async {
    Logger logger = Logger();
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      logger.f("Singing In");
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      logger.e('Error logging in: $e');
      return null;
    }
  }

// Send email verification
  static Future<void> sendVerificationEmail(User user) async {
    Logger logger = Logger();

    if (!user.emailVerified) {
      try {
        await user.sendEmailVerification();
        logger.i('Verification email sent');
      } catch (e) {
        logger.e('Failed to send verification email: $e');
      }
    }
  }

//Send password recovery email
  static Future<void> sendPasswordRecoveryEmail(
      String email, BuildContext context) async {
    Logger logger = Logger();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email enviado, revisa tu bandeja de entrada')),
        );
      }

      logger.i('Password recovery email sent');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error: No se pudo enviar el email para recuperar la contraseña')),
        );
      }
      logger.e('Failed to send password recovery email: $e');
    }
  }
}
