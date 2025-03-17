
import 'package:driver_app/features/auth/view/pages/no_registered_page.dart';
import 'package:driver_app/features/auth/view/pages/sign_in_page.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/pages/driver_app.dart';

import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:provider/provider.dart';

class DriverDataWrapper extends StatelessWidget {
  const DriverDataWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return FutureBuilder<GUser?>(
      future: authViewModel.getAuthenticatedDriver(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the data
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          GUser? guser = snapshot.data;
          if (guser == null) {
            return const SignInPage();
          }
          //Check if Driver have access granted by Admin
          if (guser.access == Access.denied) {
            return const NotRegisteredPage();
          }
          //Check if it is Driver account
          if (!guser.role.contains(Roles.driver)) {
            return const NotRegisteredPage();
          }
          sharedProvider.driver = guser;
          return const DriverApp();
        } else {
          logger.i("There is NOT info of ${snapshot.data}");
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }
}
