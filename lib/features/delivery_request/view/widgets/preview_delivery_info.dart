import 'dart:async';

import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/custom_audio_player.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PreviewDeliveryInfo extends StatefulWidget {
  final DeliveryRequestModel testModel;
  const PreviewDeliveryInfo({super.key, required this.testModel});

  @override
  State<PreviewDeliveryInfo> createState() => _PreviewDeliveryInfoState();
}

class _PreviewDeliveryInfoState extends State<PreviewDeliveryInfo> {
  final logger = Logger();


  //Destination point
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Polyline polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Completer<GoogleMapController> mapController = Completer();
  LatLng? destination;
  String? duration;
  String? distance;

  @override
  void initState() {
    super.initState();
    //Set destination point
    setDestinationPoint();
  }

  void setDestinationPoint() async {
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final deliveryRequestProvider =
        Provider.of<DeliveryRequestViewModel>(context, listen: false);
    if (widget.testModel.requestType == RequestType.byCoordinates) {
      destination = widget.testModel.information.pickUpCoordinates;
    } else {
      destination = widget.testModel.information.currentCoordenates;
    }

    try {
      //add destination marker
      markers.add(
        Marker(
          markerId: MarkerId(
            destination.toString(),
          ),
          position: destination!,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
      //add car marker
      markers.add(
        Marker(
          markerId: MarkerId(
            destination.toString(),
          ),
          position: LatLng(sharedProvider.driverCurrentPosition!.latitude,
              sharedProvider.driverCurrentPosition!.longitude),
          icon: sharedProvider.taxiIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      //Draw route
      final LatLng startPoint = LatLng(
          sharedProvider.driverCurrentPosition!.latitude,
          sharedProvider.driverCurrentPosition!.longitude);
      final response = await deliveryRequestProvider.getRoutePolylines(
          startPoint, destination!);
      if (response != null) {
        distance = response.distance;
        duration = response.duration;
        polylineFromPickUpToDropOff = Polyline(
          polylineId: const PolylineId(""),
          points: response.polylinePoints,
          color: Colors.blue,
          width: 5,
        );
        setState(() {});
      }
      //Fit car marker and destination marker
      final controller = await mapController.future;
      List<LatLng> markersToFit = [
        startPoint,
        destination!,
      ];
      await deliveryRequestProvider.fitMarkersToBounds(
          markers: markersToFit, mapController: controller);
    } catch (e) {
      logger.e("Error Draw route / fir markers:$e ");
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel = Provider.of<DeliveryRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        //width: 600,
        // height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con botón de cerrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalles de la encomienda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 5),
            RequestTypeCard(requestTypeT: widget.testModel.requestType),
            const SizedBox(height: 5),
            //Text info / audio
            //BY coords
            if (widget.testModel.requestType == RequestType.byCoordinates)
              Column(
                children: [
                  //Recipent name
                  Row(
                    children: [
                      const Text("Destinatario: ",style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(widget.testModel.details.recipientName),
                    ],
                  ),
                  //Details
                  Container(
                    height: 70,
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.testModel.details.details,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            //Audio
            if (widget.testModel.requestType == RequestType.byRecordedAudio)
              CustomAudioPlayer(
                byAudioIndicationsURL: widget.testModel.information.audioFilePath,
              ),

            //Text indications
            if (widget.testModel.requestType == RequestType.byTexting)
              Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.testModel.information.indicationText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            //Time and distance
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  //Duration
                  if(duration!=null)
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const Text('Duración'),
                          Text(
                            // '${calculateDuration(widget.ride.startTime, widget.ride.endTime).inMinutes} mins',
                            "$duration",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //Distance
                  const SizedBox(width: 100),
                  if(distance!=null)
                  Row(
                    children: [
                      const Icon(Icons.route_outlined),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const Text('Distancia'),
                          Text(
                            "$distance",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Mapa
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: destination ?? const LatLng(-1.662011, -78.660632),
                    // San Francisco
                    zoom: 12,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  markers: markers,
                  polylines: {polylineFromPickUpToDropOff},
                  onMapCreated: (GoogleMapController controller) {
                    mapController.complete(controller);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  color: Colors.grey,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  child: const Text("Aplicar"),
                  onPressed: ()async {
                    // Acción al aplicar
                    Navigator.of(context).pop();
                    //
                    //Update Delivery request model in provider
                    deliveryRequestViewModel.deliveryRequestModel = widget.testModel;
                    //    sharedProvider.passengerInformation = deliveryRequestModel.information;
                    //Write driver data in realtime database
                    await deliveryRequestViewModel.writeDriverDataUnderDeliveryRequest(
                        sharedProvider, context);
                    //Navigate to map page, display info and start navigating
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showDeliveryPreviewDialog(BuildContext context, DeliveryRequestModel deliveryRequestModel) {
  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (BuildContext context) {
      return PreviewDeliveryInfo(testModel: deliveryRequestModel);
    },
  );
}
