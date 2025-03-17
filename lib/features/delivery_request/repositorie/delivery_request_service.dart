import 'package:driver_app/shared/models/g_user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class DeliveryRequestService {
  //TRANSACTION: Write Driver data under passanger delivery reuqest
  static Future<bool> writeDriverDataOnce(
      String passengerId, Position position, GUser driver) async {
    final Logger logger = Logger();
    final databaseRef =
        FirebaseDatabase.instance.ref('delivery_requests/$passengerId/driver');
    logger.f("TEST WR: Passenger id: $passengerId , ");
    try {
      final result = await databaseRef.runTransaction((currentData) {
        // Abort if the path already contains data
        if (currentData != null) {
          return Transaction.abort();
        }

        // Write the driver's data
        return Transaction.success({
          driver.id: "",
        });
      });

      if (result.committed) {
        logger.i('Driver written successfully: ${driver.id}');
        return true; // Return true if the transaction was successful
      } else {
        logger.i('Driver already exists. Write aborted.');
        return false; // Return false if the transaction was aborted
      }
    } catch (e) {
      logger.e('Error during transaction: $e');
      return false; // Return false if an error occurs
    }
  }

  //Update "status" field under 'driver/driverId' node
  static Future<void> updateDeliveryRequestStatus(
      String passengerId, String status) async {
    final Logger logger = Logger();
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance
          .ref('delivery_requests/$passengerId/status');
      // Update the status
      await databaseRef.set(status);
      logger.i(
          'Successfully updated driver status to :$status for driverId: $passengerId');
    } catch (e) {
      logger.e('Failed to update driver status: $e');
    }
  }

  /// Removes a node at the path `delivery_requests/passengerID` in Firebase Realtime Database.
  static Future<void> removeDeliveryRequest(String passengerId) async {
    final Logger logger = Logger();
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('delivery_requests/$passengerId');

      await ref.remove();

      logger.i('Node at delivery_requests/$passengerId successfully removed.');
    } catch (e) {
      logger.e('Failed to remove node at delivery_requests/$passengerId: $e');
    }
  }
}
