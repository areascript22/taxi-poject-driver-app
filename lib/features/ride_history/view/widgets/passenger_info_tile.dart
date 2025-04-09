import 'package:driver_app/features/ride_history/view/widgets/circle_button.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/features/ride_history/viewmodel/ride_history_viewmodel.dart';
import 'package:driver_app/shared/models/passenger_model.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class PassengerInfoTile extends StatelessWidget {
  final String passengerId;
  const PassengerInfoTile({
    super.key,
    required this.passengerId,
  });

  @override
  Widget build(BuildContext context) {
    final sharedUtil = SharedUtil();
    final rideHistoryViewmodel =
        Provider.of<RideHistoryViewmodel>(context, listen: false);
    return FutureBuilder(
      future: rideHistoryViewmodel.getPassengerById(passengerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
              child:
                  Text('No se pudo recuperar los datos. Intentalo mas tarde.'));
        } else {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }
          PassengerModel passenger = snapshot.data!;
          return Column(
            children: [
              //Passenger info
              Container(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //ProfileImage
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: passenger.profilePicture.isNotEmpty
                            ? FadeInImage.assetNetwork(
                                placeholder: 'assets/img/no_image.png',
                                image: passenger.profilePicture,
                                fadeInDuration:
                                    const Duration(milliseconds: 50),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : Image.asset(
                                'assets/img/default_profile.png',
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                      ),
                    ),
                    //Remaining info
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          '${passenger.name} ${passenger.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Ionicons.star,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              passenger.ratings.totalRatingScore.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //Comunication options
              const CustomDevider(),
              Row(
                children: [
                  CircleButton(
                    icon: Ionicons.logo_whatsapp,
                    label: "Contactar",
                    onPressed: () {
                      sharedUtil.launchWhatsApp(passenger.phone);
                    },
                  ),
                ],
              ),
              const CustomDevider(),
            ],
          );
        }
      },
    );

    //
  }
}
