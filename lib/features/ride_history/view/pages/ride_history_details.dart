import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/ride_history/view/widgets/by_audio_details.dart';
import 'package:driver_app/features/ride_history/view/widgets/by_coords_details.dart';
import 'package:driver_app/features/ride_history/view/widgets/by_test_details.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/features/ride_history/view/widgets/passenger_info_tile.dart';
import 'package:driver_app/features/ride_history/viewmodel/ride_history_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class RideHistoryDetails extends StatelessWidget {
  final RideHistoryModel ride;
  const RideHistoryDetails({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final sharedProvider = Provider.of<SharedProvider>(context);
    GUser? driver = sharedProvider.driver;
    if (driver == null) {
      logger.e("Error: There is not driver data");
      return const CircularProgressIndicator(
        color: Colors.red,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          formatTimestamp(ride.startTime),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ChangeNotifierProvider(
        create: (context) => RideHistoryViewmodel(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //POR COORDENADAS
              if (ride.requestType ==  RequestType.byCoordinates)
                ByCoordsDetails(ride: ride),

              //BY TEXT MESSAGE
              if (ride.requestType == RequestType.byTexting)
                ByTextDetails(ride: ride),

              //BY VOICE MESSAGE
              if (ride.requestType == RequestType.byRecordedAudio)
                ByAudioDetails(ride: ride),

              //Driver Info
              const CustomDevider(),
              PassengerInfoTile(
                passengerId: ride.passengerId,
              ),
              //Comunication options

              // Row(
              //   children: [
              //     CircleButton(
              //       icon: Ionicons.call,
              //       label: "Contactar",
              //       onPressed: () {},
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

//To format timestamp
String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
