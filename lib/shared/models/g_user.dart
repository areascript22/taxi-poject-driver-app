import 'package:driver_app/shared/models/ratings.dart';

class DriverRideStatus {
  static const String pending = 'pending';
  static const String goingToPickUp = 'goingToPickUp';
  static const String arrived = 'arrived';
  static const String goingToDropOff = 'goingToDropOff';
  static const String finished = 'finished';
  static const String canceled = 'canceled';
  static const String reserved = 'reserved';
}

class Availability {
  static const String online = 'online';
  static const String offline = 'offline';
}

class Access {
  static const String granted = 'granted';
  static const String denied = 'denied';
}

class Roles {
  static const String driver = 'driver';
  static const String passenger = 'passenger';
  static const String admin = 'admin';
  static const String superUser = 'superUser';
}

//To be Saved in Firestore
class GUser {
  //General user
  final String? id;
  final String name;
  final String? lastName;
  final String? email;
  final String phone;
  final String profilePicture;
  final Ratings ratings;
  final List<String> role;
  final Vehicle? vehicle;
  final String access;
  String? deviceToken; //For sending push notifications

  GUser({
    this.id,
    required this.name,
    this.lastName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.ratings,
    required this.role,
    this.vehicle,
    required this.access,
    required this.deviceToken,
  });

  // Convert a map (Firestore document) to a GUser object
  factory GUser.fromMap(Map map, {String? id}) {
    return GUser(
      id: id,
      name: map['name'] ?? '',
      lastName: map['lastName'],
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      ratings: Ratings.fromMap(map['ratings'] ?? {}),
      role: List<String>.from(map['role'] ?? []),
      vehicle: map['vehicle'] != null ? Vehicle.fromMap(map['vehicle']) : null,
      access: map['access'] ?? '',
      deviceToken: map['cMToken'] ?? '',
    );
  }

  // Convert a GUser object to a map (Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      //  'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'ratings': ratings.toMap(),
      'role': role,
      'vehicle': vehicle?.toMap(),
      'access': access,
      'deviceToken': deviceToken,
    };
  }

  //get highest role
  String getHighestRole() {
    final roles = role;
    if (roles.isEmpty) return '';
    if (roles.length == 1) return roles.first;

    const hierarchy = [
      Roles.superUser,
      Roles.admin,
      Roles.driver,
      Roles.passenger,
    ];

    for (var role in hierarchy) {
      if (roles.contains(role)) {
        return role;
      }
    }

    return 'Desconocido'; // por si no coincide con nada
  }

  //Can I Manage another user
  bool canManageUser(GUser target) {
    //If I am trying to manage my own access data
    if (id == target.id) {
      return false;
    }

    List<String> currentUserRoles = role;
    if (currentUserRoles.contains(Roles.superUser)) {
      return true; // superUser can manage anyone
    }

    if (currentUserRoles.contains(Roles.admin)) {
      // Admin can't manage other admins or superUsers
      return !target.role
          .any((role) => role == Roles.admin || role == Roles.superUser);
    }

    // Drivers/passengers can't manage anyone
    return false;
  }

  /// Actualiza los campos con base en el mapa recibido
  GUser copyWithMap(Map<String, dynamic> data) {
    return GUser(
      id: id,
      name: data['name'] ?? name,
      lastName: data['lastName'] ?? lastName,
      email: data['email'] ?? email,
      phone: data['phone'] ?? phone,
      profilePicture: data['profilePicture'] ?? profilePicture,
      ratings:
          data['ratings'] != null ? Ratings.fromMap(data['ratings']) : ratings,
      role: data['role'] != null ? List<String>.from(data['role']) : role,
      vehicle: data['vehicle'] != null
          ? vehicle!.copyWithMap(data['vehicle'])
          : vehicle,
      access: data['access'] ?? access,
      deviceToken: data['deviceToken'] ?? deviceToken,
    );
  }
}

class Vehicle {
  final String carRegistrationNumber;
  final String taxiCode;
  final String model;
  final String license;

  // Constructor
  Vehicle({
    required this.carRegistrationNumber,
    required this.taxiCode,
    required this.model,
    required this.license,
  });

  // Convert a Firestore document to a Vehicle object
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      carRegistrationNumber: map['carRegistrationNumber'] ?? '',
      taxiCode: map['taxiCode'] ?? '',
      model: map['model'] ?? '',
      license: map['license'] ?? '',
    );
  }

  // Convert a Vehicle object to a map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'carRegistrationNumber': carRegistrationNumber,
      'taxiCode': taxiCode,
      'model': model,
      'license': license,
    };
  }

  //copyWithMap
  Vehicle copyWithMap(Map<String, dynamic> data) {
    return Vehicle(
      carRegistrationNumber:
          data['carRegistrationNumber'] ?? carRegistrationNumber,
      taxiCode: data['taxiCode'] ?? taxiCode,
      model: data['model'] ?? model,
      license: data['license'] ?? license,
    );
  }
}
