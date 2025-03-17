import 'package:driver_app/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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
    //  final AuthService authService = AuthService();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(
                Icons.person_2_outlined,
                size: 150,
              ),
              Text(
                "Verifica tu email para continuar. ",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              const Text(
                'Revisa tu correo electronico y abre el enlace de verificacion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              AuthGradientButton(
                  child: const Text(
                    'Inisiar sesion',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.currentUser?.reload().then((_) {
                      bool emailVerified =
                          FirebaseAuth.instance.currentUser?.emailVerified ??
                              false;
                      if (emailVerified) {
                        logger.i('Email is verified');
                        widget.rebuild();
                        // Proceed with navigation or other logic
                      } else {
                        logger.e('Email is still not verified');

                        //Toast
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Verifica tu email para continuar")));
                      }
                    }).catchError((error) {
                      // Handle errors
                      logger.e('Error reloading user: $error');
                    });
                  }),

              //Resend Verification Email
              const SizedBox(height: 20),
              AuthGradientButton(
                child: const Text(
                  'Reenviar email de verificación',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  // Resend verification email
                  if (user != null && !user.emailVerified) {
                    await user.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Verification email sent!')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
