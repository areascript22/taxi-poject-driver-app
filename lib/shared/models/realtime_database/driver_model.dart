import 'package:firebase_database/firebase_database.dart';

//To fetch driver data from Firebase Realtime Database
class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String profilePicture;
  final double rating;
  final String vehicleModel;
  final String carRegistrationNumber;
  final String deviceToken;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.rating,
    required this.vehicleModel,
    required this.carRegistrationNumber,
    required this.deviceToken,
  });

  // Factory constructor to create a DriverModel instance from Firestore DocumentSnapshot
  factory DriverModel.fromFirestore(DataSnapshot doc, String id) {
    final data = doc.value as Map<dynamic, dynamic>;
    return DriverModel(
      id: id, // Use the snapshot's key as the ID
      name: data['name'] as String,
      phone: data['phone'] as String,
      profilePicture: data['profilePicture'] as String,
      rating: (data['rating'] as num).toDouble(),
      vehicleModel: data['vehicleModel'] as String,
      carRegistrationNumber: data['carRegistrationNumber'] as String,
      deviceToken: data['deviceToken'] ?? '',
    );
  }

  // Factory constructor to create a DriverModel instance from a Map<String, dynamic>
  factory DriverModel.fromMap(Map map, String id) {
    return DriverModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      rating: (map['rating'] as num).toDouble(),
      vehicleModel: map['vehicleModel'] ?? '',
      carRegistrationNumber: map['carRegistrationNumber'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
    );
  }

  // Method to convert a DriverModel instance to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'rating': rating,
      'vehicleModel': vehicleModel,
      'carRegistrationNumber': carRegistrationNumber,
      'deviceToken': deviceToken,
    };
  }
}
