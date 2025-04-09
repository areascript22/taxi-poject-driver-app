import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/widgets/request_type_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecondPassengerTile extends StatelessWidget {
  final PassengerInformation secondPassengerInfo;
  const SecondPassengerTile({
    super.key,
    required this.secondPassengerInfo,
  });

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    String requestType = '';
    switch (secondPassengerInfo.requestType) {
      case RequestType.byCoordinates:
        requestType = "Coordenadas";
        break;
      case RequestType.byRecordedAudio:
        requestType = "Mensaje de voz";
        break;
      case RequestType.byTexting:
        requestType = "Mensaje de texto";
        break;
      default:
        requestType = "Por defecto";
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: secondPassengerInfo.profilePicture.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'assets/img/default_profile.png',
                    image: secondPassengerInfo.profilePicture,
                    fadeInDuration: const Duration(milliseconds: 150),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          secondPassengerInfo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RequestTypeCard(requestTypeT: requestType),
          ],
        ),
        titleAlignment: ListTileTitleAlignment.top,
        trailing: PopupMenuButton<int>(
          onSelected: (value) async {
            switch (value) {
              case 0:
                //Cancel ride
                await rideRequestViewModel.cancelSecondRide();
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 0,
              child: Text("Cancelar"),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
