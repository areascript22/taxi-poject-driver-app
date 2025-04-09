import 'dart:io';

import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final logger = Logger();
  // Login with email and password
  static Future<bool> loginWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    Logger logger = Logger();

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.f("User: ${userCredential.user}");
      return true;
    } on FirebaseAuthException catch (e) {
      logger.e('FirebaseAuthException during login: ${e.code} - ${e.message}');
      if (e.code == 'invalid-credential') {
        ToastMessageUtil.showToast(
            "El correo o contraseña son incorrectos", context);
      }
      return false;
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
  //Send password recovery email
  static Future<void> sendPasswordRecoveryEmail(
      String email, BuildContext context) async {
    Logger logger = Logger();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ToastMessageUtil.showToast(
            "Email enviado, revisa tu bandeja de entrada para establecer tu contraseña",
            context);
      }

      logger.i('Password recovery email sent');
    } catch (e) {
      if (context.mounted) {
        ToastMessageUtil.showToast(
            "Error: No se pudo enviar el email para recuperar la contraseña",
            context);
      }
      logger.e('Failed to send password recovery email: $e');
    }
  }

  /// Crea una cuenta con email y contraseña
  static Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      // Puedes personalizar los mensajes de error aquí
      logger.e('Error al registrar: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      logger.e('Error inesperado: $e');
      return false;
    }
  }

  // Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String uid) async {
    final Logger logger = Logger();
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('users/profile_image/$uid');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e('Error uploading image: $e');
      return null;
    }
  }
}
