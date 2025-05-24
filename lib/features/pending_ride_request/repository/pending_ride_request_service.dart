import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PendingRideRequestService {
  // Static function to write data to Firebase Realtime Database
  // static Future<bool> addDriverToRideRequest(
  //     String passengerId, String driverId, BuildContext context) async {
  //   final logger = Logger();
  //   DatabaseReference rideRef = FirebaseDatabase.instance
  //       .ref()
  //       .child('driver_requests/$passengerId/driver');

  //   try {
  //     bool rideAssigned = await rideRef.runTransaction((currentData) {

  //       if (currentData == null) {
  //         return Transaction.success(driverId); // Assign driver
  //       }
  //       return Transaction.abort(); // Another driver is already assigned
  //     }).then((transactionResult) => transactionResult.committed);
  //     return rideAssigned;
  //   } catch (e) {
  //     logger
  //         .e('Error assigning driver $driverId to passenger $passengerId: $e');
  //     return false;
  //   }
  // }

  static Future<bool> addDriverToRideRequest(
    String passengerId,
    String driverId,
    BuildContext context,
  ) async {
    final logger = Logger();
    final DatabaseReference rideRef =
        FirebaseDatabase.instance.ref().child('driver_requests/$passengerId');

    try {
      // 1. Intentamos asignar el conductor con una transacción atómica
      final transactionResult = await rideRef.runTransaction((currentData) {
        if (currentData == null || currentData is! Map) {
          return Transaction
              .abort(); // No existe la solicitud o estructura inválida
        }

        if (currentData['driver'] != null) {
          return Transaction
              .abort(); // Ya tiene conductor, no se puede asignar otro
        }

        // Asignamos este conductor
        final updatedData = Map<String, dynamic>.from(currentData);
        updatedData['driver'] = driverId;
        return Transaction.success(updatedData);
      });

      if (!transactionResult.committed) {
        logger.i("No se pudo asignar el conductor (ya estaba tomado o error)");
        return false;
      }

      // 2. Si la transacción tuvo éxito, borramos la solicitud (ya está asignada)
      await rideRef.remove(); // Eliminamos para que nadie más la vea
      logger.i("Conductor $driverId asignado y solicitud eliminada con éxito");
      return true;
    } catch (e) {
      logger.e("Error al asignar conductor: $e");
      return false;
    }
  }

  //Remove request
  static Future<bool> removeRideRequest(String passengerId) async {
    final logger = Logger();
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('driver_requests/$passengerId');

      await ref.remove();

      logger.i('Ride request for passenger $passengerId removed successfully.');
      return true;
    } catch (e) {
      logger.e('Error removing ride request for passenger $passengerId: $e');
      return false;
    }
  }
}
