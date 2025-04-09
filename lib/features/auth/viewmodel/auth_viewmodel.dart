import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/features/auth/repository/firestore_service.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class AuthViewModel extends ChangeNotifier {
  final logger = Logger();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController taxiCodeController = TextEditingController();
  final TextEditingController licenceTypeController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
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
  Future<void> signIn(
      String email, String password, BuildContext context) async {
    loading = true;
    await AuthService.loginWithEmailAndPassword(email, password, context);
    loading = false;
  }

  //Send verification email only if Email address is not verified yet
  Future<void> sendPasswordRecoveryEmail(
      String email, BuildContext context) async {
    loading = true;
    await AuthService.sendPasswordRecoveryEmail(email, context);
    loading = false;
  }

  //Create Account
  Future<void> createAccount(BuildContext context) async {
    //valdate
    if (passwordController.text != passwordConfirmController.text) {
      ToastMessageUtil.showToast("Las contraseñas no coincide", context);
      return;
    }
    //Upload Data
    loading = true;
    final response = await AuthService.registerWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    

    loading = false;
  }
}
