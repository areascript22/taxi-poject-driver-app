import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  //GEt Passenger data from Firestore, only is passenger us authenticated
  static Future<GUser?> getAuthenticatedDriver() async {
    final Logger logger = Logger();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('g_user')
            .doc(user.uid)
            .get();
        logger.e("Raw Data Retrieved: ${userData.data()}");
        if (userData.exists) {
          return GUser.fromMap(userData.data() as Map, id: userData.id);
        } else {
          return null;
        }
      } else {
        logger.e("Error: User is not authenticated");
        return null;
      }
    } catch (e) {
      logger.e("Error al obtner datos de usuario: $e");
      return null;
    }
  }
}
