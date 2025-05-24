import 'package:driver_app/core/theme/theme.dart';
import 'package:driver_app/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:driver_app/features/auth/view/pages/splash_screen.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/features/pending_ride_request/viewmodel/pending_ride_request_viewmodel.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/firebase_options.dart';

import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/providers/shared_updater.dart';
import 'package:driver_app/shared/repositorie/local_stogare_service.dart';
import 'package:driver_app/shared/repositorie/track_location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await startBackgroundService();
  LocalStorageService.setupHive();

  runApp(
    MultiProvider(
      providers: [
        //TODO : Modify the scope of each porvider
        ChangeNotifierProvider(
          create: (_) => SharedProvider()
        ),
        ChangeNotifierProvider(create: (_) => SharedUpdater()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => RideRequestViewModel()),
        ChangeNotifierProvider(create: (_) => DeliveryRequestViewModel()),
        ChangeNotifierProvider(create: (_) => PendingRideRequestViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel())
      ],
      child: const MyApp(),
    ),
  );
}

//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaxiGo Conductor',
      theme: lightMode,
      darkTheme: darkMode,
      home: const SplashScreen(),
    );
  }
}
