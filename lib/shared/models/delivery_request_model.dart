import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryRequestModel {
  final String passengerId;
  final PassengerInformation information;
  final Details details; // Adjust this type to match your details model
  final String status;
  final String requestType;
  final String timestamp;

  DeliveryRequestModel({
    required this.passengerId,
    required this.information,
    required this.details,
    required this.status,
    required this.requestType,
    required this.timestamp,
  });

  /// Factory constructor to create a DeliveryRequest from a map
  factory DeliveryRequestModel.fromMap(Map map, String passengerId) {
    return DeliveryRequestModel(
      passengerId: passengerId,
      information: PassengerInformation.fromMap(map['information']),
      details: Details.fromMap(map['details'] ?? {}),
      status: map['status'] as String,
      requestType: map['requestType'],
      timestamp: map['timestamp'],
    );
  }

  /// Converts the DeliveryRequest instance into a map
  Map<String, dynamic> toMap() {
    return {
      'information': information.toMap(),
      'details': details,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

class Details {
  final String details;
  final String recipientName;

  Details({
    required this.details,
    required this.recipientName,
  });

  /// Factory constructor to create a DeliveryRequest from a map
  factory Details.fromMap(Map map) {
    return Details(
      details: map['details'] ?? '',
      recipientName: map['recipientName'] ?? '',
    );
  }

  /// Converts the DeliveryRequest instance into a map
  Map<String, dynamic> toMap() {
    return {
      'details': details,
      'recipientName': recipientName,
    };
  }
}

class PassengerInformation {
  final String name;
  final String phone;
  final String profilePicture;
  final String audioFilePath;
  final String indicationText;
  final String pickUpLocation;
  final String dropOffLocation;
  final String requestType;
  final LatLng pickUpCoordinates;
  final LatLng dropOffCoordinates;
  final LatLng currentCoordenates;
  final String deviceToken;
  final double rating;

  PassengerInformation({
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.audioFilePath,
    required this.indicationText,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.requestType,
    required this.pickUpCoordinates,
    required this.dropOffCoordinates,
    required this.currentCoordenates,
    required this.deviceToken,
    required this.rating,
  });

  /// Factory constructor to create a PassengerInformation instance from a map
  factory PassengerInformation.fromMap(Map map) {
    return PassengerInformation(
      name: map['name'] as String,
      phone: map['phone'] as String,
      profilePicture: map['profilePicture'] as String,
      audioFilePath: map['audioFilePath'] as String,
      indicationText: map['indicationText'] as String,
      pickUpLocation: map['pickUpLocation'] ?? '',
      dropOffLocation: map['dropOffLocation'] ?? '',
      requestType: map['requestType'] ?? '',
      pickUpCoordinates: LatLng(
        map['pickUpCoordenates']['latitude'] as double,
        map['pickUpCoordenates']['longitude'] as double,
      ),
      dropOffCoordinates: LatLng(
        map['dropOffCoordenates']['latitude'] as double,
        map['dropOffCoordenates']['longitude'] as double,
      ),
      currentCoordenates: LatLng(
        map['currentCoordenates']['latitude'] as double,
        map['currentCoordenates']['longitude'] as double,
      ),
      deviceToken: map['deviceToken'] ?? '',
      rating: map['rating'] != null ? map['rating'] as double : 0.0,
    );
  }

  /// Converts the PassengerInformation instance into a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'audioFilePath': audioFilePath,
      'indicationText': indicationText,
      'pickUpLocation': pickUpLocation,
      'dropOffLocation': dropOffLocation,
      'requestType': requestType,
      'pickUpCoordenates': {
        'latitude': pickUpCoordinates.latitude,
        'longitude': pickUpCoordinates.longitude,
      },
      'dropOffCoordenates': {
        'latitude': dropOffCoordinates.latitude,
        'longitude': dropOffCoordinates.longitude,
      },
      'currentCoordenates': {
        'latitude': currentCoordenates.latitude,
        'longitude': currentCoordenates.longitude,
      },
      'deviceToken': deviceToken,
    };
  }
}
