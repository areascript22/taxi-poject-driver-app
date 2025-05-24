import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

class AdminService {
  static final Logger logger = Logger();
  //give and remove access
  static Future<bool> updateAccess({
    required String documentId,
    required String access,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('g_user')
          .doc(documentId)
          .update({'access': access});
      return true;
    } catch (e) {
      print('Error al actualizar el acceso: $e');
      return false;
    }
  }

  //

  // Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String uid) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('users/profile_image/$uid');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e('Error uploading image: $e');
      return null;
    }
  }

  static Future<bool> updatePassengerDataInFirestore(
      Map<String, dynamic> valuesDriver,
      Map<String, dynamic> valuesVehicle,
      String driverId) async {
    logger.i("SERVICE: $valuesDriver    id:$driverId");

    try {
      // Update driver data information
      if (valuesDriver.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('g_user')
            .doc(driverId)
            .update(valuesDriver)
            .then((value) => null)
            .catchError((error) {
          logger.e("Error: $error");
        });
      }

      // Update vehicle info
      if (valuesVehicle.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('g_user')
            .doc(driverId)
            .update({'vehicle': valuesVehicle})
            .then((value) => null)
            .catchError((error) {
              logger.e("Error: $error");
            });
      }

      return true;
    } catch (e) {
      logger.e("Error updating passenger data in Firestore: ${e.toString()}");
      return false;
    }
  }

  //Delete user account
  static Future<Object> deleteUser({
    required String userIdToDelete,
  }) async {
    try {
      // Call Firebase Cloud Function
      final functions = FirebaseFunctions.instance;
      final callable =
          functions.httpsCallable('deleteUser'); // Must match CF name

      final response = await callable.call({
        'userId': userIdToDelete.trim(),
      });

      logger.i('Success: ${response.data}');
      return Succes(code: 200, response: "Conductor eliminado correctamente");
    } on FirebaseFunctionsException catch (e) {
      logger.f("Error: $e");
      return Failure(code: 404, errorResponse: "Error en el servidor");
    } catch (e) {
      return Failure(
          code: 404, errorResponse: "Error al eliminar el conductor");
    }
  }
}
