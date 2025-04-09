import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({Key? key}) : super(key: key);

  @override
  State<HomePage1> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;

  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );
    log("$res: OVERLAY");
    _receivePort.listen((message) {
      log("message from OVERLAY: $message");
      setState(() {
        latestMessageFromOverlay = 'Latest Message From Overlay: $message';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isPermissionGranted();
                log("Is Permission Granted: $status");
              },
              child: const Text("Check Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                log("status: $res");
              },
              child: const Text("Request Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                if (await FlutterOverlayWindow.isActive()) return;
                await FlutterOverlayWindow.showOverlay(
                  enableDrag: true,
                  flag: OverlayFlag.defaultFlag,
                  visibility: NotificationVisibility.visibilityPublic,
                  positionGravity: PositionGravity.none,
                  height: (MediaQuery.of(context).size.height * 0.2).toInt(),
                  startPosition: const OverlayPosition(0, -259),
                );
              },
              child: const Text("Show Overlay"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isActive();
                log("Is Active?: $status");
              },
              child: const Text("Is Active?"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                log('Try to close');
                FlutterOverlayWindow.closeOverlay()
                    .then((value) => log('STOPPED: alue: $value'));
              },
              child: const Text("Close Overlay"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                homePort ??=
                    IsolateNameServer.lookupPortByName(_kPortNameOverlay);
                homePort?.send('Send to overlay: ${DateTime.now()}');
              },
              child: const Text("Send message to overlay"),
            ),
            const SizedBox(height: 20),
            Text(latestMessageFromOverlay ?? ''),
          ],
        ),
      ),
    );
  }
}
