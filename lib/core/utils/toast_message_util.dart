import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessageUtil {
  static final FToast _fToast = FToast();

  static void showToast(String message, BuildContext context) {
    _fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/img/launcher_icon_d.jpeg', // Replace with your app icon path
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(milliseconds: 2500), // Custom duration
    );
  }
}
