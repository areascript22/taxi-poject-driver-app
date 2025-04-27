import 'package:driver_app/features/delivery_request/model/delivery_status.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/widgets/custom_audio_player.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class DeliveryInfoCard extends StatefulWidget {
  const DeliveryInfoCard({super.key});

  @override
  State<DeliveryInfoCard> createState() => _DeliveryInfoCardState();
}

class _DeliveryInfoCardState extends State<DeliveryInfoCard> {
  final sharedUtil = SharedUtil();
  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: deliveryRequestViewModel.deliveryRequestModel != null
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
                      Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          children: [
                            UserAvatar(
                                imageUrl: deliveryRequestViewModel
                                    .deliveryRequestModel!
                                    .information
                                    .profilePicture),
                            Text(
                              deliveryRequestViewModel
                                  .deliveryRequestModel!.information.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              deliveryRequestViewModel
                                  .deliveryRequestModel!.information.rating
                                  .toString(),
                            ),
                          ],
                        ),
                      ),
                      //Locations pick-up and drop-off
                      const SizedBox(width: 20),

                      //Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //type
                            RequestTypeCard(
                                requestTypeT: deliveryRequestViewModel
                                    .deliveryRequestModel!.requestType),
                            const SizedBox(height: 4.0),
                            //By Coords
                            if (deliveryRequestViewModel
                                    .deliveryRequestModel!.requestType ==
                                RequestType.byCoordinates)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Pick Up location
                                    Row(
                                      children: [
                                        const Icon(
                                          Ionicons.location,
                                          color: Colors.green,
                                        ),
                                        Expanded(
                                          child: Text(
                                            deliveryRequestViewModel
                                                .deliveryRequestModel!
                                                .information
                                                .pickUpLocation,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //Drop off location
                                    // Row(
                                    //   children: [
                                    //     const Icon(
                                    //       Ionicons.location,
                                    //       color: Colors.blue,
                                    //     ),
                                    //     Expanded(
                                    //       child: Text(
                                    //         deliveryRequestViewModel
                                    //             .deliveryRequestModel!
                                    //             .information
                                    //             .dropOffLocation,
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    //Details
                                    const SizedBox(height: 6.0),
                                    Row(
                                      children: [
                                        Text(
                                          'Detinatario',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '·',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Flexible(
                                          child: Text(
                                            deliveryRequestViewModel
                                                .deliveryRequestModel!
                                                .details
                                                .recipientName,
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Detalles',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          deliveryRequestViewModel
                                              .deliveryRequestModel!
                                              .details
                                              .details,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            //By AUdio
                            if (deliveryRequestViewModel
                                    .deliveryRequestModel!.requestType ==
                                RequestType.byRecordedAudio)
                              CustomAudioPlayer(
                                byAudioIndicationsURL: deliveryRequestViewModel
                                    .deliveryRequestModel!
                                    .information
                                    .audioFilePath,
                              ),
                            //By text
                            if (deliveryRequestViewModel
                                    .deliveryRequestModel!.requestType ==
                                RequestType.byTexting)
                              Text(
                                deliveryRequestViewModel.deliveryRequestModel!
                                    .information.indicationText,
                              )
                          ],
                        ),
                      ),

                      //Comunication options
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (deliveryRequestViewModel
                                      .deliveryRequestModel ==
                                  null) {
                                return;
                              }
                              sharedUtil.launchWhatsApp(deliveryRequestViewModel
                                  .deliveryRequestModel!.information.phone);
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
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.goingForThePackage)
                    CustomElevatedButton(
                      onTap: () =>
                          deliveryRequestViewModel.updateDeliveryRequestStatus(
                              DeliveryStatus.haveThePackage, context),
                      child: const Text("Tengo el paquete"),
                    ),

                  //'HE LLEGADO' button
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.haveThePackage)
                    CustomElevatedButton(
                      onTap: () =>
                          deliveryRequestViewModel.updateDeliveryRequestStatus(
                              DeliveryStatus.arrivedToTheDeliveryPoint,
                              context),
                      child: const Text("He llegado con el paquete"),
                    ),
                  //'FINALIZAR' button
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.passengerHasThePakcage)
                    CustomElevatedButton(
                      onTap: () async {
                        await deliveryRequestViewModel
                            .updateDeliveryRequestStatus(
                                DeliveryStatus.finished, context);
                      },
                      child: const Text("Finalizar entraga"),
                    ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
