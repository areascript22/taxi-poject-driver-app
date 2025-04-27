import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:driver_app/features/auth/view/widgets/password_textfield.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final repeatPasswordTextController = TextEditingController();
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
                              //Icon
                              const Icon(Icons.person_2_outlined, color: Colors.purple, size: 160,),
                              //Content
                              const Text(
                                "Crea tu cuenta",
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "",
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
                              PasswordTextfield(
                                textEditingController: repeatPasswordTextController,
                                isObscureText: true,
                                hintText: 'Repetir la contraseña',
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
                                  'Registrarse',
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
                                   await authViewModel.signUp( emailTextController.text,passwordTextController.text, repeatPasswordTextController.text, context);

                                  }
                                },
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
