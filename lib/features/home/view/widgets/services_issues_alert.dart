import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServicesIssueAlert extends StatelessWidget {
  final Map dataMap;
  const ServicesIssueAlert({super.key, required this.dataMap});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    //Defina letters color
    late Color textColor;
    if (dataMap['priority'] == 0) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () async {
        switch (dataMap['priority']) {
          case 0:
            break;
          case 1:
            await homeViewModel.requestPermissionsAtUserLevel(sharedProvider);
            break;
          case 2:
            await homeViewModel.requestLocationServiceSystemLevel();
            break;
          default:
        }
      },
      child: Container(
        color: dataMap['color'],
        height: 60.0,
        child: Center(
          child: ListTile(
            leading: dataMap['priority'] == 0
                ? const Icon(
                    Icons.wifi_off_outlined,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
            title: Text(
              dataMap['title'],
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              dataMap['content'],
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
