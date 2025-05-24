import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/auth/view/pages/create_account_page.dart';
import 'package:driver_app/features/auth/view/pages/no_registered_page.dart';
import 'package:driver_app/features/auth/view/pages/sign_in_page.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/pages/driver_app.dart';

import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:provider/provider.dart';

class DriverDataWrapper extends StatefulWidget {
  const DriverDataWrapper({super.key});

  @override
  State<DriverDataWrapper> createState() => _DriverDataWrapperState();
}

class _DriverDataWrapperState extends State<DriverDataWrapper> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? listenerAccess;
  final bool _isVerifiedToPass = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenToAccess();
  }

  //Listener
  void listenToAccess() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    listenerAccess = FirebaseFirestore.instance
        .collection('g_user')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        final access = snapshot.get('access');
        print('Access actualizado: $access');

        if (access == Access.granted) {
          // Go to home page

          setState(() {});
        }
      } else {
        print('Documento no existe');
      }
    }, onError: (e) {
      print('Error al escuchar los cambios: $e');
    });
  }

  @override
  void dispose() {
    super.dispose();
    listenerAccess?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context);
    //
    // if(_isVerifiedToPass){
    //   //get driver data
    //
    //   listenerAccess?.cancel();
    //   return const DriverApp();
    // }

    //
    return FutureBuilder<GUser?>(
      future: authViewModel.getAuthenticatedDriver(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the data
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          GUser? guser = snapshot.data;
          if (guser == null) {
            return const SignInPage();
          }
          if (guser.access == Access.denied) {
            return NotRegisteredPage(
              onUpdate: () {
                setState(() {});
              },
            );
          }
          //Check if it is Driver account
          if (!guser.role.contains(Roles.driver)) {
            return NotRegisteredPage(
              onUpdate: () => setState(() {}),
            );
          }
          listenerAccess?.cancel();
          sharedProvider.driver = guser;
          return const DriverApp();
        } else {
          //Check if Driver have access granted by Admi
          logger.i("There is NOT info of ${snapshot.data}");
          return const CreateAccountPage();
        }
      },
    );
  }
}
