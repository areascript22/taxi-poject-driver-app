import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:flutter/material.dart';

class ByTextDetails extends StatelessWidget {
  final RideHistoryModel ride;
  const ByTextDetails({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomDevider(),
          const Text(
            "Indicaciónes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(ride.indicationText),
        ],
      ),
    );
  }
}
