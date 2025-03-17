import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideHistoryModel {
  String? rideId;
  String driverId;
  String passengerId;
  LatLng pickupCoords;
  LatLng dropoffCoords;
  String pickUpLocation;
  String dropOffLocation;
  Timestamp startTime;
  Timestamp endTime;
  double distance;
  String driverName;
  String passengerName;
  String status;
  String requestType;
  String audioFilePath;
  String indicationText;

  RideHistoryModel({
    this.rideId,
    required this.driverId,
    required this.passengerId,
    required this.pickupCoords,
    required this.dropoffCoords,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.driverName,
    required this.passengerName,
    required this.status,
    required this.requestType,
    required this.audioFilePath,
    required this.indicationText,
    
  });

  // Convert a document from Firestore into a RideHistory instance
  factory RideHistoryModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return RideHistoryModel(
      rideId: data['rideId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      pickupCoords: data['pickupLocation'] != null
          ? LatLng(data['pickupLocation']['latitude'],
              data['pickupLocation']['longitude'])
          : const LatLng(0, 0),
      dropoffCoords: data['dropoffLocation'] != null
          ? LatLng(data['dropoffLocation']['latitude'],
              data['dropoffLocation']['longitude'])
          : const LatLng(0, 0),
      pickUpLocation: data['pickUpLocation'] ?? '',
      dropOffLocation: data['dropOffLocation'] ?? '',
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      distance: (data['distance'] ?? 0).toDouble(),
      driverName: data['driverName'] ?? '',
      passengerName: data['passengerName'] ?? '',
      status: data['status'] ?? '',
      requestType: data['requestType'] ?? 'byCoordinates',
      audioFilePath:data['audioFilePath']??'',
      indicationText: data['indicationText']??''
    );
  }

  // Convert a RideHistory instance into a map to be uploaded to Firestore
  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'pickupLocation': {
        'latitude': pickupCoords.latitude,
        'longitude': pickupCoords.longitude,
      },
      'dropoffLocation': {
        'latitude': dropoffCoords.latitude,
        'longitude': dropoffCoords.longitude,
      },
      'pickUpLocation': pickUpLocation,
      'dropOffLocation': dropOffLocation,
      'startTime': startTime,
      'endTime': endTime,
      'distance': distance,
      'driverName': driverName,
      'passengerName': passengerName,
      'status': status,
      'requestType': requestType,
      'indicationText':indicationText,
      'audioFilePath':audioFilePath,
    };
  }
}
