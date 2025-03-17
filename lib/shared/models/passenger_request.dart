import 'package:driver_app/shared/models/delivery_request_model.dart';

class PassengerRequest {
  final String passengerId;
  final String status;
  final String type;
  final PassengerInformation information;
  PassengerRequest({
    required this.passengerId,
    required this.status,
    required this.type,
    required this.information,
  });

  factory PassengerRequest.fromMap(Map value) {
    return PassengerRequest(
      passengerId: value['passengerId'] as String,
      status: value['status'] as String,
      type: value['type'] as String,
      information: PassengerInformation.fromMap(value['information']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'status': status,
      'type': type,
      'information': information.toMap(),
    };
  }
}
