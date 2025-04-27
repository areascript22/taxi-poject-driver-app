import 'dart:async';
import 'package:driver_app/features/auth/view/pages/driver_data_wrapper.dart';
import 'package:driver_app/features/auth/view/pages/email_verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class EmailVerificationWrapper extends StatefulWidget {
  const EmailVerificationWrapper({super.key});

  @override
  State<EmailVerificationWrapper> createState() => _EmailVerificationWrapperState();
}

class _EmailVerificationWrapperState extends State<EmailVerificationWrapper> {
  late User? _user;
  late Timer _timer;
  final logger = Logger();


  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    // Verifica periódicamente si el correo fue verificado
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      logger.f("Checking if Email Verified");
      await _user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        timer.cancel();
        setState(() {
          _user = refreshedUser;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("No hay usuario autenticado.")),
      );
    }

    if (_user!.emailVerified) {
      _timer.cancel();
      return const DriverDataWrapper();
    } else {
      return EmailVerificationPage(rebuild: () {
        setState(() {}); // En caso quieras forzar una actualización desde dentro de la otra página
      });
    }
  }
}
