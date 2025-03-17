import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class DeliveryRequestListTile extends StatelessWidget {
  final DeliveryRequestModel deliveryRequestModel;

  const DeliveryRequestListTile({
    super.key,
    required this.deliveryRequestModel,
  });

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);

    return GestureDetector(
      onTap: () async {
        if (sharedProvider.availavilityState == Availability.offline) {
          ToastMessageUtil.showToast(
            "Cambia tu estado a disponible para aceptar la encomienda.",context
          );
          return;
        }
        //Update Delivery request model in provider
        deliveryRequestViewModel.deliveryRequestModel = deliveryRequestModel;
        //    sharedProvider.passengerInformation = deliveryRequestModel.information;
        //Write driver data in realtime database
        await deliveryRequestViewModel
            .writeDriverDataUnderDeliveryRequest(sharedProvider, context);
        //Navigate to map page, display info and start navigating
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
                  UserAvatar(
                      imageUrl:
                          deliveryRequestModel.information.profilePicture),
                  Text(
                    deliveryRequestModel.information.name,
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
                    //reqeust type card
                    RequestTypeCard(
                      requestType: deliveryRequestModel.requestType,
                    ),
                    //Reqeust info
                    const SizedBox(height: 5),
                    if (deliveryRequestModel.requestType ==
                        RequestType.byCoordinates)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deliveryRequestModel.information.pickUpLocation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            deliveryRequestModel.information.dropOffLocation,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Text(
                                'Detalles',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                '·',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  deliveryRequestModel.details.details,
                                  style: TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
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
