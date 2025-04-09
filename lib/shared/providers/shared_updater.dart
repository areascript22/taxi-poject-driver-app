import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';

class SharedUpdater extends ChangeNotifier {
  String _availabilityState = Availability.offline;
  bool _weAreInDanger = false;
  
  //Getters
  String get availabilityState => _availabilityState;
  bool get weAreInDanger => _weAreInDanger;
  //Setters
  set availabilityState(String value) {
    _availabilityState = value;
    notifyListeners();
  }

  set weAreInDanger(bool value) {
    _weAreInDanger = value;
    notifyListeners();
  }
  //Functions
}
