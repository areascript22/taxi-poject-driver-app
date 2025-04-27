import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:driver_app/shared/models/g_user.dart';
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

  //Sign Up with Email and Password
  static Future<Object> signUpWithEmailAndPassword(
      String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enviar correo de verificación (opcional)
      await userCredential.user?.sendEmailVerification();

      logger.f("User: ${userCredential.user}");

      return Succes(
        code: 200,
        response:
            'Usuario creado, revisa tu bandeja de entrada para verificar tu email',
      );
    } on FirebaseAuthException catch (e) {
      logger
          .e('FirebaseAuthException during sign up: ${e.code} - ${e.message}');

      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está en uso. Intenta iniciar sesión.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'La creación de cuentas con correo y contraseña está deshabilitada.';
          break;
        case 'weak-password':
          errorMessage =
              'La contraseña es demasiado débil. Usa al menos 6 caracteres.';
          break;
        default:
          errorMessage =
              'Error al intentar crear su cuenta. Intente nuevamente.';
          break;
      }

      return Failure(
        code: 500,
        errorResponse: errorMessage,
      );
    } catch (e) {
      logger.e('Unexpected error during sign up: $e');
      return Failure(
        code: 500,
        errorResponse: 'Ocurrió un error inesperado. Intenta nuevamente.',
      );
    }
  }

// Send email verification
//   static Future<void> sendVerificationEmail(User user) async {
//     Logger logger = Logger();
//
//     if (!user.emailVerified) {
//       try {
//         await user.sendEmailVerification();
//         logger.i('Verification email sent');
//       } catch (e) {
//         logger.e('Failed to send verification email: $e');
//       }
//     }
//   }

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

  //Save user data in Firestore
  //Save user data in Firestore
  static Future<bool> saveDriverDataInFirestore(GUser driver) async {
    final Logger logger = Logger();
    try {
      await FirebaseFirestore.instance
          .collection('g_user')
          .doc(driver.id)
          .set(driver.toMap());
      return true;
    } catch (e) {
      logger.e("Error adding user data in Firestore: ${e.toString()}");
      return false;
    }
  }

  //Remove profile image
  static Future<Object> deleteProfileImage(String uid) async {
    try {
      // Crea una referencia a la imagen en Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('users/profile_image/$uid');

      // Elimina el archivo
      await storageRef.delete();

      print("Imagen eliminada exitosamente de Firebase Storage.");
      return Succes(code: 200, response: "La imagen se ha eliminado.");
    } on FirebaseException catch (e) {
      // Captura errores relacionados con Firebase (como falta de permisos o referencia inexistente)
      if (e.code == 'object-not-found') {
        print("Error: La imagen no se encontró.");
        return Failure(code: 404, errorResponse: "La imagen no existe.");
      } else if (e.code == 'unauthorized') {
        print("Error: Permisos insuficientes.");
        return Failure(code: 403, errorResponse: "No tienes permisos suficientes para eliminar la imagen.");
      } else if (e.code == 'cancelled') {
        print("Error: La operación fue cancelada.");
        return Failure(code: 400, errorResponse: "La operación fue cancelada.");
      } else {
        // Otro tipo de error relacionado con Firebase
        print("Error desconocido: ${e.message}");
        return Failure(code: 500, errorResponse: "Error desconocido: ${e.message}");
      }
    } catch (e) {
      // Captura cualquier otro tipo de error
      print("Error al eliminar la imagen: $e");
      return Failure(code: 500, errorResponse: "No se pudo eliminar la imagen.");
    }
  }
  // Método estático para eliminar datos en Firestore en la ruta "g_user/uid"
  static Future<Object> deleteUserData(String uid) async {
    try {
      // Obtén la referencia al documento de Firestore
      final documentRef = FirebaseFirestore.instance.collection('g_user').doc(uid);

      // Intenta eliminar el documento
      await documentRef.delete();

      print("Datos eliminados exitosamente de Firestore.");
      return Succes (code: 200, response: "Los datos han sido eliminados.");
    } on FirebaseException catch (e) {
      // Captura errores relacionados con Firebase (como falta de permisos o documento inexistente)
      if (e.code == 'not-found') {
        print("Error: El documento no se encontró.");
        return Failure(code: 404, errorResponse: "El documento no existe.");
      } else if (e.code == 'permission-denied') {
        print("Error: Permisos insuficientes.");
        return Failure(code: 403, errorResponse: "No tienes permisos suficientes para eliminar los datos.");
      } else {
        // Otro tipo de error relacionado con Firebase
        print("Error desconocido: ${e.message}");
        return Failure(code: 500, errorResponse: "Error desconocido: ${e.message}");
      }
    } catch (e) {
      // Captura cualquier otro tipo de error
      print("Error al eliminar los datos: $e");
      return Failure(code: 500, errorResponse: "No se pudo eliminar los datos.");
    }
  }
}
