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
            title: Text(
              dataMap['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              dataMap['content'],
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
