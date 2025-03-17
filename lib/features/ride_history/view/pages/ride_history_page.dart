import 'package:driver_app/features/ride_history/view/widgets/ride_history_tile.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated");
      return const Center(
        child: Text("Error: No está autenticado."),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis viajes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_history')
            .where('driverId', isEqualTo: driverId) // Filter by driverId
            //.orderBy('startTime', descending: true) // Order by most recent
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching ride history'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ride history available.'));
          }

          final rideHistoryList = snapshot.data!.docs
              .map((doc) => RideHistoryModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: rideHistoryList.length,
            itemBuilder: (context, index) {
              final ride = rideHistoryList[index];
              return RideHistoryTile(ride: ride);
            },
          );
        },
      ),
    );
  }
}

