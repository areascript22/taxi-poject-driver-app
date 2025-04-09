import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideHistoryModel {
  String? rideId;
  String driverId;
  String passengerId;
  LatLng pickupCoords;
  LatLng dropoffCoords;
  String pickUpLocation;
  Timestamp startTime;
  Timestamp endTime;
  String passengerName;
  String driverName;
  String status;
  String requestType;
  String audioFilePath;
  String indicationText;
  String sector;
  DateTime timesTamp;

  RideHistoryModel({
    this.rideId,
    required this.driverId,
    required this.passengerId,
    required this.pickupCoords,
    required this.dropoffCoords,
    required this.pickUpLocation,
    required this.startTime,
    required this.endTime,
    required this.passengerName,
    required this.driverName,
    required this.status,
    required this.requestType,
    required this.audioFilePath,
    required this.indicationText,
    required this.sector,
    required this.timesTamp,
  });

  // Convert a document from Firestore into a RideHistory instance
  factory RideHistoryModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return RideHistoryModel(
      rideId: data['rideId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      pickupCoords: data['pickupCoords'] != null
          ? LatLng(data['pickupCoords']['latitude'],
              data['pickupCoords']['longitude'])
          : const LatLng(0, 0),
      dropoffCoords: data['dropoffCoords'] != null
          ? LatLng(data['dropoffCoords']['latitude'],
              data['dropoffCoords']['longitude'])
          : const LatLng(0, 0),
      pickUpLocation: data['pickUpLocation'] ?? 'n/a',
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      passengerName: data['passengerName'] ?? 'n/a',
      driverName: data['driverName'] ?? 'n/a',
      status: data['status'] ?? '',
      requestType: data['requestType'] ?? 'byCoordinates',
      audioFilePath: data['audioFilePath'] ?? '',
      indicationText: data['indicationText'] ?? '',
      sector: data['sector'] ?? 'Desconocido',
      timesTamp:
          data['timesTamp'] is DateTime ? data['timesTamp'] : DateTime.now(),
    );
  }

  // Convert a RideHistory instance into a map to be uploaded to Firestore
  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'pickupCoords': {
        'latitude': pickupCoords.latitude,
        'longitude': pickupCoords.longitude,
      },
      'dropoffCoords': {
        'latitude': dropoffCoords.latitude,
        'longitude': dropoffCoords.longitude,
      },
      'pickUpLocation': pickUpLocation,
      'startTime': startTime,
      'endTime': endTime,
      'passengerName': passengerName,
      'driverName': driverName,
      'status': status,
      'requestType': requestType,
      'indicationText': indicationText,
      'audioFilePath': audioFilePath,
      'sector': sector,
      'timesTamp': timesTamp,
    };
  }
}
