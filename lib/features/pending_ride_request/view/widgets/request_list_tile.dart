import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/pending_ride_request/model/pending_request_model.dart';
import 'package:driver_app/features/pending_ride_request/view/widgets/sector_card.dart';
import 'package:driver_app/features/pending_ride_request/viewmodel/pending_ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';

import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PendingRequestListTile extends StatelessWidget {
  final PendingRequestModel pendingRideRequestModel;

  PendingRequestListTile({
    super.key,
    required this.pendingRideRequestModel,
  });

  final sharedUtil = SharedUtil();

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    //  playAudios();
    final pendingRideRequestViewModel =
        Provider.of<PendingRideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return GestureDetector(
      onTap: () async {
        if (sharedProvider.driverRideStatus != DriverRideStatus.pending) {
          ToastMessageUtil.showToast(
              "Ya tiene una carrera en progreso.", context);
          return;
        }
        if (sharedProvider.availavilityState == Availability.offline) {
          ToastMessageUtil.showToast(
              "Cambia tu estado a disponible para aceptar la encomienda.",
              context);

          return;
        }
        sharedProvider.sector =
            pendingRideRequestModel.sector ?? 'Sector no registrado';
        await pendingRideRequestViewModel.addDriverToRideRequest(
            pendingRideRequestModel.key, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Profile picture
              Column(
                children: [
                  UserAvatar(imageUrl: pendingRideRequestModel.profilePicture),
                  Text(
                    pendingRideRequestModel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Ionicons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      Text("Nuevo"),
                    ],
                  ),
                ],
              ),

              //Content
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Reqeust type card
                    RequestTypeCard(
                        requestTypeT: pendingRideRequestModel.requestType),
                    //sector
                    const SizedBox(height: 5),
                    SectorCard(sector: pendingRideRequestModel.sector),
                    //Pick Up Location
                    const SizedBox(height: 15),
                    if (pendingRideRequestModel.requestType ==
                        RequestType.byCoordinates)
                      Row(
                        children: [
                          const Icon(
                            Ionicons.location,
                            color: Colors.green,
                          ),
                          Expanded(
                            child: Text(
                              pendingRideRequestModel.pickUpLocation,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                    if (pendingRideRequestModel.requestType !=
                        RequestType.byCoordinates)
                      Row(
                        children: [
                          const Icon(
                            Ionicons.location,
                            color: Colors.green,
                          ),
                          Text(
                            pendingRideRequestModel.currentLocation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
