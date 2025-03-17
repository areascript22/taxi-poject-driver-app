import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

class RideHistoryUtil {
  //Convert an image from assets into a value useful for Icons in the map
  static Future<BitmapDescriptor?> convertImageToBitmapDescriptor(
      String path) async {
    try {
      final ByteData byteData = await rootBundle.load(path);
      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image originalImage = img.decodeImage(bytes)!;
      img.Image resizedImage =
          img.copyResize(originalImage, width: 100, height: 100);
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resizedImage));
      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);
      return icon;
    } catch (e) {
      return null;
    }
  }

  //convert duration from Routes to int value
  static int extractMinutes(String duration) {
    RegExp regex = RegExp(r'\d+'); // Extracts numeric digits
    Match? match = regex.firstMatch(duration);

    if (match != null) {
      return int.parse(match.group(0)!); // Convert extracted value to int
    }

    return 0; // Default to 0 if no match is found
  }
}
