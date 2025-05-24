import 'package:cloud_firestore/cloud_firestore.dart';

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class RideRequest {
  final String passengerName;
  final String requestType;  // Changed to String
  final Coordinates dropoffCoords;
  final String? indicationText;
  final Timestamp timestamp;
  final String? rideId;
  final String? audioFilePath;
  final String driverId;
  final Coordinates pickupCoords;
  final String passengerId;
  final String driverName;
  final Timestamp startTime;
  final Timestamp endTime;
  final String sector;
  final String pickUpLocation;
  final String status;  // Changed to String

  RideRequest({
    required this.passengerName,
    required this.requestType,
    required this.dropoffCoords,
    this.indicationText,
    required this.timestamp,
    this.rideId,
    this.audioFilePath,
    required this.driverId,
    required this.pickupCoords,
    required this.passengerId,
    required this.driverName,
    required this.startTime,
    required this.endTime,
    required this.sector,
    required this.pickUpLocation,
    required this.status,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      passengerName: json['passengerName'] as String,
      requestType: json['requestType'] as String,
      dropoffCoords: Coordinates.fromJson(
          Map<String, dynamic>.from(json['dropoffCoords'] as Map)),
      indicationText: json['indicationText'] as String?,
      timestamp: json['timesTamp'] as Timestamp,
      rideId: json['rideId'] as String?,
      audioFilePath: json['audioFilePath'] as String?,
      driverId: json['driverId'] as String,
      pickupCoords: Coordinates.fromJson(
          Map<String, dynamic>.from(json['pickupCoords'] as Map)),
      passengerId: json['passengerId'] as String,
      driverName: json['driverName'] as String,
      startTime: json['startTime'] as Timestamp,
      endTime: json['endTime'] as Timestamp,
      sector: json['sector'] as String,
      pickUpLocation: json['pickUpLocation'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passengerName': passengerName,
      'requestType': requestType,
      'dropoffCoords': dropoffCoords.toJson(),
      'indicationText': indicationText,
      'timesTamp': timestamp,
      'rideId': rideId,
      'audioFilePath': audioFilePath,
      'driverId': driverId,
      'pickupCoords': pickupCoords.toJson(),
      'passengerId': passengerId,
      'driverName': driverName,
      'startTime': startTime,
      'endTime': endTime,
      'sector': sector,
      'pickUpLocation': pickUpLocation,
      'status': status,
    };
  }

  // Helper method to calculate ride duration in seconds
  int get durationInSeconds {
    return endTime.seconds - startTime.seconds;
  }

  // Helper methods for common status checks
  bool get isCanceled => status.toLowerCase() == 'canceled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isInProgress => status.toLowerCase() == 'inprogress';
  bool get isPending => status.toLowerCase() == 'pending';
}