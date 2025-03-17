import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int minutes; // The starting countdown value in minutes

  const CountdownTimer({
    super.key,
    required this.minutes,
  });

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    totalSeconds = widget.minutes * 60; // Convert minutes to seconds
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        setState(() {
          totalSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  String get formattedTime {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Text(
        formattedTime,
        style: const TextStyle(
            fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}
