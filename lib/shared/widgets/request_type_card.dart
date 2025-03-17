import 'package:driver_app/shared/models/request_type.dart';
import 'package:flutter/material.dart';

class RequestTypeCard extends StatelessWidget {
  final String requestType;
  const RequestTypeCard({
    super.key,
    required this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    String requestTypeT = '';
    switch (requestType) {
      case RequestType.byCoordinates:
        requestTypeT = "Coordenadas";
        break;
      case RequestType.byRecordedAudio:
        requestTypeT = "Mensaje de voz";
        break;
      case RequestType.byTexting:
        requestTypeT = "Mensaje de texto";
        break;
      default:
        requestTypeT = "Por defecto";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50], // Light blue background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Text(
        requestTypeT, // Example request type
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[800], // Dark blue text
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
