import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/ratings.dart';

class PassengerModel {
  final String? id;
  final String email;
  final String name;
  final String lastName;
  final String phone;
  final String profilePicture;
  final Ratings ratings;

  // Constructor
  PassengerModel({
    this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.profilePicture,
    required this.ratings,
  });

  // Factory method to create an instance from Firestore data
  factory PassengerModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map; // Retrieve data from Firestore document
    return PassengerModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      ratings: Ratings.fromMap(data['ratings']),
    );
  }

  // Optionally, you can add a method to convert the object back to a Map for Firestore write operations
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'lastName': lastName,
      'phone': phone,
      'profilePicture': profilePicture,
      'ratings': ratings.toMap(),
    };
  }
}
