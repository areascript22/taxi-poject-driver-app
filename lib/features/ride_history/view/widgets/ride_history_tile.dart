import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/pending_ride_request/view/widgets/sector_card.dart';
import 'package:driver_app/features/ride_history/view/pages/ride_history_details.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class RideHistoryTile extends StatelessWidget {
  final RideHistoryModel ride;

  const RideHistoryTile({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
  
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideHistoryDetails(
              ride: ride,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cliente: ${ride.passengerName}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              //If It's by Coords
              if (ride.requestType == RequestType.byCoordinates)
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Ionicons.location,
                          color: Colors.green,
                        ),
                        Text(ride.pickUpLocation),
                      ],
                    ),
                    //Drop off
                  ],
                ),

              if (ride.requestType == RequestType.byTexting)
                Container(
                  padding: const EdgeInsets.all(3),
                  // child: Text(ride),
                ),
              const SizedBox(height: 8),
              //Text('Distancia: ${ride.distance.toStringAsFixed(2)} km'),
              // Text('Status: ${ride.status}'),
              Text(
                'Fecha: ${formatTimestamp(ride.startTime)}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RequestTypeCard(requestTypeT: ride.requestType),
                  const SizedBox(width: 15),
                  SectorCard(sector: ride.sector),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }
}
