import 'package:driver_app/features/auth/view/pages/auth_wrapper_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const  AuthWrapper()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     Theme.of(context).colorScheme.background,
          //     Theme.of(context).colorScheme.inversePrimary,
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60), // Makes it rounded
                  child: Image.asset(
                    'assets/img/launcher_icon_d.jpeg',
                    width: 220,
                    height: 220,
                    fit: BoxFit
                        .cover, // Ensures the image covers the circular shape
                  ),
                ),

                // Image.asset('assets/img/launcher_icon_p.jpeg',
                //     width: 120, height: 120),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const Text(
                  "TaxiGo Conductor",
                  style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
