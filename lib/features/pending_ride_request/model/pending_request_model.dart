class PendingRequestModel {
  final String key;
  final String dropOffLocation;
  final String currentLocation;
  final String name;
  final String pickUpLocation;
  final String profilePicture;
  final String requestType;

  PendingRequestModel({
    required this.key,
    required this.dropOffLocation,
    required this.currentLocation,
    required this.name,
    required this.pickUpLocation,
    required this.profilePicture,
    required this.requestType,
  });

  // Factory method to create an instance from JSON
  factory PendingRequestModel.fromJson(Map json, String key) {
    return PendingRequestModel(
      key: key,
      dropOffLocation: json['dropOffLocation'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
      name: json['name'] ?? '',
      pickUpLocation: json['pickUpLocation'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      requestType: json['requestType'] ?? '',
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'dropOffLocation': dropOffLocation,
      'currentLocation':currentLocation,
      'name': name,
      'pickUpLocation': pickUpLocation,
      'profilePicture': profilePicture,
      'requestType': requestType,
    };
  }
}
