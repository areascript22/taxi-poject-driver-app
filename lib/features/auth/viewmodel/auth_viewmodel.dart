import 'dart:io';

import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/features/auth/repository/firestore_service.dart';
import 'package:driver_app/features/auth/view/pages/auth_wrapper_page.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/ratings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Future<void> signIn(String email, String password,
      BuildContext context) async {
    loading = true;
    await AuthService.loginWithEmailAndPassword(email, password, context);
    loading = false;
  }

  //Sign up
  Future<void> signUp(String email, String password, String password2,
      BuildContext context) async {
    //validate
    if (password != password2) {
      ToastMessageUtil.showToast("Las contraseñas no coinciden", context);
      return;
    }
    //init sign up
    loading = true;
    final response =
    await AuthService.signUpWithEmailAndPassword(email, password);
    if (response is Failure) {
      final resp = response;
      if (context.mounted) {
        ToastMessageUtil.showToast(resp.errorResponse, context);
      }
      loading = false;
      return;
    }
    //Success
    if (context.mounted && response is Succes) {
      ToastMessageUtil.showToast(response.response, context);
      Navigator.pop(context);
    }
    loading = false;
  }

  //Send verification email only if Email address is not verified yet
  Future<void> sendPasswordRecoveryEmail(String email,
      BuildContext context) async {
    loading = true;
    await AuthService.sendPasswordRecoveryEmail(email, context);
    loading = false;
  }

  //Send verification email o
  Future<void> sendVerificationEmail(
      BuildContext context) async {
    loading = true;
    try{
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    }catch(e){
      if(context.mounted){
        ToastMessageUtil.showToast("No se pudo enviar el email de verificación", context);
      }
      logger.e("Error al enviar email de verificación");
    }
    loading = false;
  }

  //Create Account
  Future<void> createAccount(BuildContext context, File imageFile) async {
    //check if we are logged in
    final currentDriver = FirebaseAuth.instance.currentUser;
    if (currentDriver == null) {
      return;
    }
    //Upload Data
    loading = true;
    //Upload image and get Url
    final String? imageUrl =
    await AuthService.uploadImage(imageFile, currentDriver.uid);
    if (imageUrl == null && context.mounted) {
      ToastMessageUtil.showToast(
          "No se pudo cargar la imagen, intentelo de nuevo", context);
      return;
    }
    //ratings
    final Ratings ratings = Ratings(
      rating: 0,
      ratingCount: 0,
      totalRatingScore: 0,
    );
    //vehicle
    final Vehicle vehicle = Vehicle(
      carRegistrationNumber: placaController.text,
      taxiCode: taxiCodeController.text,
      model: vehicleModelController.text,
      license: licenceTypeController.text,);
    //Upload driverData to Firestore
    final driver = GUser(
        id: currentDriver.uid,
        name: nameController.text,
        lastName: lastnameController.text,
        email: currentDriver.email,
        phone: phoneController.text,
        profilePicture: imageUrl!,
        ratings: ratings,
        role: [Roles.driver],
        access: Access.denied,
        deviceToken: null,
        vehicle:vehicle,
    );

    final response = await AuthService.saveDriverDataInFirestore(driver);

    //navigate to DriverData Wrapper
    if (context.mounted) {
      if (response) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
              (Route<dynamic> route) => false, // Elimina todo
        );
      } else {
        ToastMessageUtil.showToast(
            "No se pudo guardar los datos, intentelo de nuevo", context);
      }
    }
    loading = false;
  }

  //check if email si veified
  Future<bool> isEmailVerified(BuildContext context) async {
    final currentDriver = FirebaseAuth.instance.currentUser;
    if (currentDriver == null) {
      return false;
    }
    if (currentDriver.emailVerified) {
      return true;
    }
    return false;
  }

  //Cancel account request
  Future<void> cancelAccountRequest(BuildContext context) async {
    //
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ToastMessageUtil.showToast("Error: NO estas autenticado", context);
      return;
    }
    //
    loading = true;
    //Remove profile image
    final response = await AuthService.deleteProfileImage(uid);
    if (response is Failure && context.mounted) {
      ToastMessageUtil.showToast(response.errorResponse, context);
      loading = false;
      return;
    }
    //Remove data from Firestore
    final responseData = await AuthService.deleteUserData(uid);
    if (responseData is Failure && context.mounted) {
      ToastMessageUtil.showToast(responseData.errorResponse, context);
      loading = false;
      return;
    }
    //Sign Out
    await FirebaseAuth.instance.signOut();
    loading = false;
  }
}
