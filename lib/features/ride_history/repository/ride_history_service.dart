import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/passenger_model.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class RideHistoryService {
  //To retrieve data  passanger data from FIrestore
  static Future<PassengerModel?> getPassengerById(String passengerId) async {
    final logger = Logger();
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('g_user')
          .doc(passengerId)
          .get();

      if (doc.exists) {
        return PassengerModel.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      logger.e("Error fetching data from Firestore:$e");
      return null;
    }
  }

  //Get addres from coords
  static Future<String?> getReadableAddress(
      double latitude, double longitude, String apiKey) async {
    final Logger logger = Logger();
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;

          for (final result in results) {
            final types = result['types'] as List<dynamic>;

            // Check if result is of type "street_address" or "route"
            if (types.contains('street_address') || types.contains('route')) {
              final addressComponents = result['address_components'] as List;

              String? street;
              String? route;

              for (final component in addressComponents) {
                final componentTypes = component['types'] as List<dynamic>;

                if (componentTypes.contains('route')) {
                  route = component['long_name'];
                } else if (componentTypes.contains('street_address') ||
                    componentTypes.contains('street_number')) {
                  street = component['long_name'];
                }
              }

              // Return the formatted address
              if (street != null && route != null) {
                return '$street, $route';
              } else if (street != null) {
                return street;
              } else if (route != null) {
                return route;
              }
            }
          }
        }

        return 'No readable address found';
      } else {
        throw Exception(
            'Failed to fetch geocoding data: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error: $e');
      return 'Error fetching address';
    }
  }
}
