import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/ride_request/view/widgets/by_coordinates_info.dart';
import 'package:driver_app/features/ride_request/view/widgets/by_text_info.dart';
import 'package:driver_app/shared/widgets/buttons/emergency_button.dart';
import 'package:driver_app/shared/widgets/custom_audio_player.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/push_notification_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/custom_circular_button.dart';
import 'package:driver_app/shared/widgets/custom_text_button.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class PassengerInfoCard extends StatefulWidget {
  const PassengerInfoCard({super.key});

  @override
  State<PassengerInfoCard> createState() => _PassengerInfoCardState();
}

class _PassengerInfoCardState extends State<PassengerInfoCard> {
  final sharedUtil = SharedUtil();
  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Column(
      children: [
        //Navigate button
        if (rideRequestViewModel.passengerInformation != null)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Open Map options to navigate
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Fit markers button
                    CustomCircularButton(
                      onPressed: () =>
                          rideRequestViewModel.fitMarkers(sharedProvider),
                      icon: const Icon(
                        Ionicons.git_branch_outline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    //navigate button
                    CustomTextButton(
                      onPressed: () {
                        rideRequestViewModel.showAvailableMaps(context);
                      },
                      child: const Text("Navegar"),
                    ),
                  ],
                ),

                //Fit all Markers  on map
                const EmergencyButton(),
              ],
            ),
          ),
        //Rest of Passenger info
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: rideRequestViewModel.passengerInformation != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      //Passenger Info.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Porfile pic
                          Column(
                            children: [
                              UserAvatar(
                                  imageUrl: rideRequestViewModel
                                      .passengerInformation!.profilePicture),
                              Text(
                                rideRequestViewModel.passengerInformation!.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                rideRequestViewModel
                                    .passengerInformation!.rating
                                    .toString(),
                              ),
                            ],
                          ),

                          //Requet content (Coords, Audio, text)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Request Type
                                RequestTypeCard(
                                  requestTypeT:
                                      rideRequestViewModel.requestType ?? '',
                                ),
                                const SizedBox(height: 5),
                                //Locations pick-up and drop-off
                                if (rideRequestViewModel.requestType ==
                                    RequestType.byCoordinates)
                                  ByCoordinatesInfo(
                                      rideRequestViewModel:
                                          rideRequestViewModel),

                                //Audio
                                if (rideRequestViewModel.requestType ==
                                    RequestType.byRecordedAudio)
                                  CustomAudioPlayer(
                                      byAudioIndicationsURL:
                                          rideRequestViewModel
                                              .byAudioIndicationsURL),

                                //text
                                if (rideRequestViewModel.requestType ==
                                    RequestType.byTexting)
                                  const ByTextInfo(),
                              ],
                            ),
                          ),

                          //Comunication options (if it is in operation mode)
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (rideRequestViewModel
                                          .passengerInformation !=
                                      null) {
                                    sharedUtil.launchWhatsApp(
                                        rideRequestViewModel
                                            .passengerInformation!.phone);
                                  }
                                },
                                icon: const Icon(
                                  Ionicons.logo_whatsapp,
                                  color: Colors.green,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      //BUTTONS
                      //'HE LLEGADO' button
                      if (rideRequestViewModel.driverRideStatus ==
                          DriverRideStatus.goingToPickUp)
                        CustomElevatedButton(
                          onTap: () {
                            //update status
                            rideRequestViewModel
                                .updateDriverStatus(DriverRideStatus.arrived);
                            //clean polylines
                            rideRequestViewModel.polylineFromPickUpToDropOff = const Polyline(polylineId: PolylineId("default"));
                            //send push notification
                            if (rideRequestViewModel.passengerInformation !=
                                null) {
                              PushNotificationService.sendPushNotification(
                                deviceToken: rideRequestViewModel
                                    .passengerInformation!.deviceToken,
                                title: "El conductor ha llegado",
                                body:
                                    "El conductor lo esta esperando, trate de llegar a tiempo",
                              );
                            }
                          },
                          child: const Text("He llegado"),
                        ),
                      //MESSAGE ""
                      if (rideRequestViewModel.driverRideStatus ==
                          DriverRideStatus.arrived)
                        const Text("El pasajero ha sido notificado.."),
                      //'HE LLEGADO' button
                      if (rideRequestViewModel.driverRideStatus ==
                          DriverRideStatus.goingToDropOff)
                        CustomElevatedButton(
                          onTap: () async {
                            //Update Status to "arrived" to notify Passenger
                            await rideRequestViewModel
                                .updateDriverStatus(DriverRideStatus.finished);
                          },
                          child: const Text("Finalizar viaje"),
                        ),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
