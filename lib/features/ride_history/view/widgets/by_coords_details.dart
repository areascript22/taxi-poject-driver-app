import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/ride_history/viewmodel/ride_history_viewmodel.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class ByCoordsDetails extends StatefulWidget {
  const ByCoordsDetails({
    super.key,
    required this.ride,
  });

  final RideHistoryModel ride;

  @override
  State<ByCoordsDetails> createState() => _ByCoordsDetailsState();
}

class _ByCoordsDetailsState extends State<ByCoordsDetails> {
  @override
  void initState() {
    super.initState();
    initializevalues();
  }

  void initializevalues() {
    final rideHistoryViewModel =
        Provider.of<RideHistoryViewmodel>(context, listen: false);
    rideHistoryViewModel.initValues(
        widget.ride.pickupCoords, widget.ride.dropoffCoords);
  }

  @override
  Widget build(BuildContext context) {
    //  final rideHistoryViewModel = Provider.of<RideHistoryViewmodel>(context);
    return Consumer<RideHistoryViewmodel>(
      builder: (context, value, child) {
        return Column(
          children: [
            //map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip
                    .hardEdge, // Ensures content inside respects the rounded corners
                child: GoogleMap(
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Example coordinates
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    value.onMapCreated(controller);
                  },
                  markers: {...value.markers},
                  polylines: {value.polylineFromPickUpToDropOff},
                ),
              ),
            ),
            //Info
            const SizedBox(height: 15),
            //pick up
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Ionicons.location, color: Colors.green),
                    Text(
                      widget.ride.pickUpLocation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                //duration
                Text(formatTimestampToTimeAMPM(widget.ride.startTime)),
              ],
            ),
            //drop off
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Ionicons.location, color: Colors.blue),
                    Text(
                      widget.ride.dropOffLocation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                //duration
                Text(formatTimestampToTimeAMPM(widget.ride.endTime)),
              ],
            ),

            //Distance and duration
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Duration
                  Row(
                    children: [
                      const Icon(Ionicons.timer_outline),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const Text('Duración'),
                          Text(
                            '${calculateDuration(widget.ride.startTime, widget.ride.endTime).inMinutes} mins',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //Distance
                  const SizedBox(width: 100),
                  Row(
                    children: [
                      const Icon(Ionicons.analytics_outline),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const Text('Distancia'),
                          Text(
                            '${widget.ride.distance} km',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String formatTimestampToTimeAMPM(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  String period = hour < 12 ? 'AM' : 'PM'; // Determine AM or PM
  hour = hour % 12; // Convert to 12-hour format (0 becomes 12)
  hour = hour == 0 ? 12 : hour; // Special case for 0 which should be 12

  String formattedHour =
      hour.toString().padLeft(2, '0'); // Ensure hour is two digits
  String formattedMinute =
      minute.toString().padLeft(2, '0'); // Ensure minute is two digits

  return '$formattedHour:$formattedMinute $period'; // Return formatted time string
}

Duration calculateDuration(Timestamp start, Timestamp end) {
  DateTime startDateTime =
      start.toDate(); // Convert start Timestamp to DateTime
  DateTime endDateTime = end.toDate(); // Convert end Timestamp to DateTime

  return endDateTime.difference(
      startDateTime); // Calculate the difference between the two DateTimes
}
