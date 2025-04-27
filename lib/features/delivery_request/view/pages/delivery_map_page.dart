import 'dart:async';

import 'package:driver_app/features/delivery_request/view/widgets/bottom_sheet_cancel_delivery.dart';
import 'package:driver_app/features/delivery_request/view/widgets/delivery_info_card.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/buttons/emergency_button.dart';
import 'package:driver_app/shared/widgets/custom_circular_button.dart';
import 'package:driver_app/shared/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  State<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  late DeliveryRequestViewModel providerToDisose;
  String _mapStyle = "";
  @override
  void initState() {
    super.initState();
    loadNecesaryData();
  }

  void loadNecesaryData() {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    providerToDisose = deliveryRequestViewModel;
    deliveryRequestViewModel.loadCustomCarIcon(sharedProvider);
    deliveryRequestViewModel
        .listenToDriverCoordenatesInFirebase(sharedProvider);
    deliveryRequestViewModel.listenToDeliveryRequestStatus(
        sharedProvider, context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapStyle();
  }

  @override
  void dispose() {
    providerToDisose.cancelListeners();
    providerToDisose.mapController = Completer();
    super.dispose();
  }

  //Update map Style
  Future<void> updateMapStyle() async {
    Brightness newBrightness = MediaQuery.of(context).platformBrightness;
    //  final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    String stylePath = newBrightness == Brightness.dark
        ? 'assets/json/dark_map_style.json'
        : 'assets/json/light_map_style.json';

    String style = await rootBundle.loadString(stylePath);
    setState(() {
      _mapStyle = style;
    });
    if (providerToDisose.mapController.isCompleted) {
      GoogleMapController controller =
          await providerToDisose.mapController.future;
      controller.setMapStyle(_mapStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                showCancelDeliveryBottomSheet(context);
              },
              child: const Text(
                "Cancelar",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          toolbarHeight: 40,
        ),
        body: Stack(
          children: [
            //Map
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-1.648920, -78.677108),
                zoom: 14,
              ),
              markers: {
                deliveryRequestViewModel.carMarker,
                ...deliveryRequestViewModel.markers
              },
              polylines: {deliveryRequestViewModel.polylineFromPickUpToDropOff},
              onMapCreated: (controller) {
                deliveryRequestViewModel.onMapCreated(controller);
                if (!deliveryRequestViewModel.mapController.isCompleted) {
                  updateMapStyle();
                }
              },
            ),
            //Messages
            if (deliveryRequestViewModel.mapMessages != null)
              Positioned(
                top: 7,
                left: 55,
                right: 55,
                child: GestureDetector(
                  onTap: () {
                    deliveryRequestViewModel.mapMessages = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deliveryRequestViewModel.mapMessages!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //Delivery information bottom sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  //Map options to navigate
                  if (deliveryRequestViewModel.deliveryRequestModel != null)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Navigate button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Animate camera to the current coords
                              CustomCircularButton(
                                onPressed: () {
                                  deliveryRequestViewModel
                                      .fitMarkers(sharedProvider);
                                },
                                icon: const Icon(
                                  Ionicons.git_branch_outline,
                                ),
                              ),
                              //asdfsadfsdf
                              const SizedBox(height: 15),
                              CustomTextButton(
                                onPressed: () => deliveryRequestViewModel
                                    .showAvailableMaps(sharedProvider, context),
                                child: const Text("Navegar"),
                              ),
                            ],
                          ),
                          const EmergencyButton()
                        ],
                      ),
                    ),
                  //Deliveru information Bottom Sheet
                  const DeliveryInfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
