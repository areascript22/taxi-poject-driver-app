import 'package:driver_app/features/auth/view/pages/create_account_page.dart';
import 'package:driver_app/features/auth/view/pages/password_recovery_page.dart';
import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:driver_app/features/auth/view/widgets/password_textfield.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // Form key for validation
  final Logger logger = Logger();
  static const platform = MethodChannel('foreground_service');

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Antes de iniciar sesión asegurate de que tu correo esté previamente registrado por el administrador.",
                                style: TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 30),
                              CustomTextField(
                                textEditingController: emailTextController,
                                hintText: 'Correo electrónico',
                                validator: (value) {
                                  value = value?.trim();
                                  emailTextController.text =
                                      emailTextController.text.trim();
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese su correo electrónico';
                                  }
                                  const emailPattern =
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                  final emailRegex = RegExp(emailPattern);
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Por favor, ingrese un correo electrónico válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              PasswordTextfield(
                                textEditingController: passwordTextController,
                                isObscureText: true,
                                hintText: 'Contraseña',
                                validator: (value) {
                                  value = value?.trim();
                                  passwordTextController.text =
                                      passwordTextController.text.trim();
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingrese su contraseña';
                                  }
                                  if (value.length < 8) {
                                    return 'La contraseña debe tener al menos 8 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              CustomElevatedButton(
                                child: !authViewModel.loading
                                    ? const Text(
                                        'Iniciar sesión',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : const CircularProgressIndicator(),
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    await authViewModel.signIn(
                                      emailTextController.text,
                                      passwordTextController.text,
                                      context,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PasswordRecoveryPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "¿Aun no tienes la contraseña?",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                        decorationThickness: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              CustomDevider(),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateAccountPage(),
                                        ),
                                      );  
                                    },
                                    child: const Text(
                                      "¿No tienes una cuenta? Registrate aquí",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                        decorationThickness: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(sharedProvider.version),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
