import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/passenger_model.dart';
import 'package:logger/logger.dart';

class RideHistoryService {
  //To retrieve data  passanger data from FIrestore
  static Future<PassengerModel?> getPassengerById(String passengerId) async {
    final logger = Logger();
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('g_user')
          .doc(passengerId)
          .get();

      if (doc.exists) {
        return PassengerModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      logger.e("Error fetching data from Firestore:$e");
      return null;
    }
  }
}
