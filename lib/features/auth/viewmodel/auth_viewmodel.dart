import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/features/auth/repository/firestore_service.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final logger = Logger();
 // Driver? driverModel;
  bool _loading = false;

  //GETTERS
  bool get loading => _loading;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //Functions
  Future<GUser?> getAuthenticatedDriver() async {
    return FirestoreService.getAuthenticatedDriver();
  }

  //Sign in
  Future<void> signIn(String email, String password,BuildContext context) async {
    loading = true;
    User? user = await AuthService.loginWithEmailAndPassword(email, password);
    if (user != null) {
      logger.e("Sending verification email : ${user.emailVerified}");

      if (!user.emailVerified) {
        await AuthService.sendVerificationEmail(user);
        logger.i("Email just verified....");
      }
    } else {
      if(context.mounted){
   ToastMessageUtil.showToast(
          "Usuario no registrado, ponte en contacto con el administrador.",context);
      }
   
    }
    loading = false;
  }

  //Send verification email only if Email address is not verified yet
  Future<void> sendPasswordRecoveryEmail(
      String email, BuildContext context) async {
    loading = true;
    await AuthService.sendPasswordRecoveryEmail(email, context);
    loading = false;
  }
}
