import 'package:driver_app/features/pending_ride_request/model/pending_request_model.dart';
import 'package:driver_app/features/pending_ride_request/view/widgets/request_list_tile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PendingRideRequestPage extends StatefulWidget {
  const PendingRideRequestPage({super.key});

  @override
  State<PendingRideRequestPage> createState() => _PendingRideRequestPageState();
}

class _PendingRideRequestPageState extends State<PendingRideRequestPage> {
  final DatabaseReference requestsRef =
      FirebaseDatabase.instance.ref('driver_requests');
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carreras pendientes"),
      ),
      body: StreamBuilder(
        stream: requestsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            //Build lists of client requests
            final data = snapshot.data!.snapshot.value as Map;

            List<MapEntry<dynamic, dynamic>> entriesRaw = data.entries.toList();
            List<MapEntry<dynamic, dynamic>> entriesToBuild = [];
            //Filter only pending requests
            entriesRaw.forEach((element) {
              // if (element.value['status'] == 'pending') {
              entriesToBuild.add(element);
              //  }
            });
            //If there is no "pending" requests
            if (entriesToBuild.isEmpty) {
              return const Center(
                  child: Text("No hay solicitudes pendientes ..."));
            }
            //Update delivery request lenght in shared prtovider

            return ListView.builder(
              itemCount: entriesToBuild.length,
              itemBuilder: (context, index) {
                //Get data raw from firebase
                var requestBody = entriesToBuild[index].value;
                //get request key
                final String requestKey = entriesToBuild[index].key;
                //get the Delivery Request model

                final deliveryRequestModel =
                    PendingRequestModel.fromJson(requestBody, requestKey);

                return PendingRequestListTile(
                    pendingRideRequestModel: deliveryRequestModel);
              },
            );
          } else {
            return const Center(
              child: Text("No hay solicitudes pendientes..."),
            );
          }
        },
      ),
    );
  }
}
