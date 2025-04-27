
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotRegisteredPage extends StatefulWidget {
  final Function onUpdate;

  const NotRegisteredPage({
    super.key,
    required this.onUpdate,
  });

  @override
  State<NotRegisteredPage> createState() => _NotRegisteredPageState();
}

class _NotRegisteredPageState extends State<NotRegisteredPage> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud en revisión'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Su solicitud esta siendo revisada por administración',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Una vez que su solicitud sea aprobada se le redirigirá automáticamente al panel principal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              //Refresh

              //
              const SizedBox(height: 30),
              const CustomDevider(),
              // Text(
              //   'Si desea crear otra cuenta e iniciar el proceso de nuevo, presione',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey[700],
              //   ),
              // ),
              // ElevatedButton.icon(
              //   onPressed: !authViewModel.loading
              //       ? () async {
              //           // Define the action, e.g., navigating to a contact page
              //           await authViewModel.cancelAccountRequest(context);
              //         }
              //       : () {},
              //   icon: !authViewModel.loading
              //       ? const Icon(Icons.contact_mail)
              //       : const CircularProgressIndicator(),
              //   label: const Text('Cancelar solicitud'),
              // ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
