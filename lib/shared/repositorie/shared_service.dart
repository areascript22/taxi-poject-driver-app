import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/utils/configuration_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class SharedService {
  static Logger logger = Logger();
  //It returns a route as polylines (it is use to update polyline in Porvider)
  static Future<RouteInfo?> getRoutePolylinePoints(
      LatLng start, LatLng end, String apiKey) async {
    final Logger logger = Logger();

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> routePoints = [];
    try {
      try {
        PolylineResult result = await polylinePoints
            .getRouteBetweenCoordinates(
              googleApiKey: apiKey,
              request: PolylineRequest(
                  origin: PointLatLng(start.latitude, start.longitude),
                  destination: PointLatLng(end.latitude, end.longitude),
                  mode: TravelMode.driving),
            )
            .timeout(const Duration(seconds: 10));
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            routePoints.add(LatLng(point.latitude, point.longitude));
          });
        }
        logger.i(
            "Result getting route: ${result.durationTexts} type: ${result.durationTexts![0]}");
        return RouteInfo(
          distance:
              result.distanceTexts != null ? result.distanceTexts![0] : "0 km",
          duration:
              result.durationTexts != null ? result.durationTexts![0] : "0 min",
          polylinePoints: routePoints,
        );
      } on TimeoutException catch (e) {
        logger.e("Timeout occurred: $e");
        return null;
      } on SocketException catch (e) {
        logger.e("Network issue: $e");
        return null;
      } catch (e) {
        logger.e("Unknown error: $e");
        return null;
      }
    } catch (e) {
      logger.e('Error fetching route: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  //To Free Up driver position in QUeue
  static Future<bool> freeUpDriverPositionInQueue() async {
    final Logger logger = Logger();
    //get driver id
    String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated..");
      return false;
    }

    try {
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref('positions');

      // Retrieve all drivers in the 'positions' node
      final snapshot = await dbRef.once().timeout(ConfigF.timeOut);
      if (snapshot.snapshot.value != null) {
        final drivers = snapshot.snapshot.value as Map?;

        // Iterate through the drivers to find the matching driverId
        if (drivers != null) {
          for (var pushKey in drivers.keys) {
            final driverData = drivers[pushKey];
            if (driverData != null && driverData['driver_id'] == driverId) {
              // If a match is found, remove the driver from the queue by removing the entry
              await dbRef.child(pushKey).remove().timeout(ConfigF.timeOut);
              logger.i('Driver $driverId removed from queue.');
              return true;
            }
          }
        }
      }
      logger.i('Driver $driverId not found in queue.');
      return true;
    } catch (e) {
      logger.e('Error removing driver: $e');
      return false;
    }
  }

  //RATINGS
  //save driver star ratings
  static Future<void> updateDriverRating(
      double newRating, String passengerId) async {
    final logger = Logger();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userRef =
        firestore.collection('g_user').doc(passengerId);

    try {
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) return;

        Map<String, dynamic> ratings = {};
        if (userSnapshot.data() != null) {
          ratings = (userSnapshot.data() as Map<String, dynamic>)['ratings'] ??
              {
                'totalRatingScore': 0.0,
                'ratingCount': 0,
                'rating': 0.0,
              };
        }

        double totalRatingScore =
            (ratings['totalRatingScore'] ?? 0.0) + newRating;
        int ratingCount = (ratings['ratingCount'] ?? 0) + 1;
        double averageRating = (totalRatingScore / ratingCount).toDouble();
        averageRating = double.parse(averageRating.toStringAsFixed(1));

        transaction.update(userRef, {
          'ratings': {
            'totalRatingScore': totalRatingScore,
            'ratingCount': ratingCount,
            'rating': averageRating,
          }
        });
      });

      logger.i("✅ Rating updated successfully.");
    } catch (e) {
      logger.e("❌ Error updating rating: $e");
    }
  }

  //Go offline
  static Future<bool> removeCurrentDriver() async {
    final logger = Logger();
    try {
      final driverId = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseDatabase.instance.ref("drivers/$driverId");
      await ref.remove().timeout(ConfigF.timeOut);
      logger.i("Driverr removed from database");
      return true;
    } catch (e) {
      logger.e("Failed to remove driver $e");
      return false;
    }
  }

  //Save driver comments
  static Future<void> addDriverComment(
      String driverId, String passengerId, String comment) async {
    final logger = Logger();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference commentsRef =
        firestore.collection('g_user').doc(passengerId).collection('comments');

    try {
      await commentsRef.add({
        'passengerId': driverId,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      logger.i("✅ Comment added successfully.");
    } catch (e) {
      logger.e("❌ Error adding comment: $e");
    }
  }

  //Emergency button (notify all drivers)
  static Future<bool> emergencyNotification(String taxiCode) async {
    try {
      final driverId = FirebaseAuth.instance.currentUser?.uid;
      final dbRef = FirebaseDatabase.instance.ref('emergency');
      await dbRef.update({
        "$driverId": {
          "taxiCode": taxiCode,
          "timestamp": ServerValue.timestamp,
        }
      });
      return true;
    } catch (e) {
      logger.e("Error while sending emergency notification: $e");
      return false;
    }
  }

  //Update Availability status
  static Future<bool> updateDriverAvailability(
      String availability, String driverRideStatus) async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    try {
      String driverId = FirebaseAuth.instance.currentUser!.uid;
      await database.child('drivers/$driverId').update({
        'availability': availability,
        'status_availability': "${driverRideStatus}_$availability",
      }).timeout(ConfigF.timeOut);
      logger.i("Driver availability updated successfully.");
      return true;
    } catch (e) {
      logger.e("Error updating availability: $e");
      return false;
    }
  }
}
