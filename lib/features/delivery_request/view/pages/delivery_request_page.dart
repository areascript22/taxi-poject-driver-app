import 'package:driver_app/features/delivery_request/view/widgets/delivery_request_list_tile.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_updater.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DeliveryRequestPage extends StatefulWidget {
  const DeliveryRequestPage({super.key});

  @override
  State<DeliveryRequestPage> createState() => _DeliveryRequestPageState();
}

class _DeliveryRequestPageState extends State<DeliveryRequestPage> {
  final DatabaseReference requestsRef =
  FirebaseDatabase.instance.ref('delivery_requests');
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    final deliveryRequestViewModel =
    Provider.of<DeliveryRequestViewModel>(context, listen: false);
    deliveryRequestViewModel.deliveryRequestPageContext = context;
  }

  @override
  Widget build(BuildContext context) {
    String availavility = Provider
        .of<SharedUpdater>(context)
        .availabilityState;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de encomiendas"),

      ),
      body: availavility == Availability.online
          ? StreamBuilder(
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

            List<MapEntry<dynamic, dynamic>> entriesRaw =
            data.entries.toList();
            List<MapEntry<dynamic, dynamic>> entriesToBuild = [];
            //Filter only pending requests
            for (var element in entriesRaw) {
              if (element.value['status'] == 'pending') {
                entriesToBuild.add(element);
              }
            }
            //If there is no "pending" requests
            if (entriesToBuild.isEmpty) {
              return const Center(
                  child: Text("No hay pedidos pendientes.."));
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
                logger.i("request body: ${entriesToBuild[index].value}");
                final deliveryRequestModel =
                DeliveryRequestModel.fromMap(requestBody, requestKey);
                logger.f(
                    "Reqeust model: ${deliveryRequestModel.requestType}");

                return DeliveryRequestListTile(
                    deliveryRequestModel: deliveryRequestModel);
              },
            );
          } else {
            return const Center(
              child: Text("No hay solicitudes pendientes.."),
            );
          }
        },
      )
          : _offlineMessage(),
    );
  }

  //Offline message
  Widget _offlineMessage() {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Icon(
            Icons.delivery_dining_sharp,
            size: 60,
            color: Colors.purple,
          ),
          Text(
            "Tu estado actual es 'APAGADO'",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Cambia tu estado a 'ENCENDIDO' para poder ver las solicitudes de Encomiendas",
          ),
        ],
      ),
    );
  }

  //


}
