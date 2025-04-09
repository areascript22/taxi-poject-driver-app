import 'package:driver_app/features/auth/view/pages/auth_wrapper_page.dart';
import 'package:driver_app/features/settings/repository/settings_service.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/local_stogare_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logger/logger.dart';

class SettingsViewModel extends ChangeNotifier {
  final logger = Logger();

  bool _loading = false;
  //getters
  bool get loading => _loading;
  //setters
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //delete account
  Future<void> deleteaccount(
      BuildContext context, SharedProvider sharedProvider) async {
    loading = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    try {
      //Background service
      final service = FlutterBackgroundService();
      await sharedProvider.goOnlineOrOffline(Availability.offline,
          sharedProvider.driverRideStatus, sharedProvider);
      service.invoke('stopService');
      await LocalStorageService.saveIsThereDataInDB(false);
      //
      final response = await SettingsService.deleteAccountPermanentely(uid);
      await FirebaseAuth.instance.signOut();
      loading = false;

      //
      //poop
      if (response && context.mounted) {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      logger.e("Erro deleting acount: $e");
    }
  }
}
