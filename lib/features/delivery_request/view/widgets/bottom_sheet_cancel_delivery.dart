import 'package:driver_app/features/delivery_request/model/delivery_status.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CancelDeliveryBottomSheett extends StatelessWidget {
  const CancelDeliveryBottomSheett({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
  //  final sharedProvider = Provider.of<SharedProvider>(context);
    final driverInfo = deliveryRequestViewModel.deliveryRequestModel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Message: Passenger is waiting for you
          if (driverInfo != null)
            Text(
              "${driverInfo.information.name} está esperando su encomienda",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          if (driverInfo != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  UserAvatar(imageUrl: driverInfo.information.profilePicture),
            ),
          const Text(
            "¿Esta seguro de que quiere cancelar?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          //BUTTON: No
          const SizedBox(height: 5),
          CustomElevatedButton(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text("No")),
          //BUTTON: Confirm cancel ride
          const SizedBox(height: 5),
          CustomElevatedButton(
            color: const Color.fromARGB(221, 213, 213, 213),
            onTap: () async {
              //Cancel ride

              await deliveryRequestViewModel.updateDeliveryRequestStatus(
                  DeliveryStatus.canceled, context);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Sí cancelar",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCancelDeliveryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const CancelDeliveryBottomSheett(),
  );
}
