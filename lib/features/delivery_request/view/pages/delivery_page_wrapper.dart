import 'package:driver_app/features/delivery_request/view/pages/delivery_map_page.dart';
import 'package:driver_app/features/delivery_request/view/pages/delivery_request_page.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryPageWrapper extends StatefulWidget {
  const DeliveryPageWrapper({super.key});

  @override
  State<DeliveryPageWrapper> createState() => _DeliveryPageWrapperState();
}

class _DeliveryPageWrapperState extends State<DeliveryPageWrapper> {
  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    // return IndexedStack(
    //   index: deliveryRequestViewModel.deliveryPageIndex,
    //   children: const [
    //     DeliveryRequestPage(),
    //     DeliveryMapPage(),
    //   ],
    // );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: buildChild(deliveryRequestViewModel.deliveryPageIndex),
    );
  }

  Widget buildChild(int index) {
    if (index == 0) {
      return const DeliveryRequestPage();
    }

    if (index == 1) {
      return const DeliveryMapPage();
    }
    return Container();
  }
}
