import 'package:driver_app/features/admin/view/pages/edit_driver_data.dart';
import 'package:driver_app/features/admin/view/widgets/acccess_card.dart';
import 'package:driver_app/features/admin/view/widgets/role_card.dart';
import 'package:driver_app/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CanceledTRipTile extends StatelessWidget {
  final String driverName;
  final String passengerName;
  final String startTime;
  final int indexInArray;

  CanceledTRipTile({
    super.key,
    required this.driverName,
    required this.indexInArray,
    required this.passengerName,
    required this.startTime,
  });

  final sharedUtil = SharedUtil();

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    return GestureDetector(
      onTap: () async {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Profile picture

              //Content
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    Text(
                      '${driverName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    //passenger name
                    Text(
                      '${passengerName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    //time
                    Text(
                      '${startTime}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    //Taxi code
                    // Text(
                    //     "Unidad: ${driverName.vehicle?.taxiCode ?? "Sin código"}"),
                    //Access
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         flex: 5,
                    //         child: AccessCard(access: driverName.access)),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //         flex: 3,
                    //         child: RoleCard(role: driverName.getHighestRole()))
                    //   ],
                    // ),
                  ],
                ),
              ),

              //Option buttons
            ],
          ),
        ),
      ),
    );
  }
}
