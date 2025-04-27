import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EmailVerificationPage extends StatefulWidget {
  final VoidCallback rebuild;

  const EmailVerificationPage({
    super.key,
    required this.rebuild,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  //Para imprimir los difernetes debgs
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authViewModel = Provider.of<AuthViewModel>(context);
    //  final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.email_outlined,
                size: 150,
                color: Colors.purple,
              ),
              Text(
                "Verifica tu email para continuar. ",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              const Text(
                'Revisa tu correo electronico, busca el enlace que se ha enviado para verificar tu correo electrónico',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const CustomDevider(),
              Text(
                'Si aun no haz recibido el email de verificación puedes volver a enviar otro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              //Resend Verification Email
              const SizedBox(height: 20),
              CustomElevatedButton(
                onTap: !authViewModel.loading
                    ? () async {
                        // Resend verification email
                        if (user != null && !user.emailVerified) {
                          await authViewModel.sendVerificationEmail(context);
                          if (context.mounted) {
                            ToastMessageUtil.showToast(
                                "Email de verificación enviado, revisa tu bandeja de entrada",
                                context);
                          }
                        }
                      }
                    : () {},
                child: !authViewModel.loading
                    ? const Text(
                        'Reenviar email de verificación',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      )
                    : const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
