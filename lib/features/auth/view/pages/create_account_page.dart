import 'dart:io';
import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:driver_app/features/auth/view/widgets/password_textfield.dart';
import 'package:driver_app/features/auth/view/widgets/phone_number_textfield.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/ratings.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final Logger logger = Logger();
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  File? _imageFile;
  bool showImageSelectError = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: CustomElevatedButton(
          onTap: () async {
            setState(() {
              showImageSelectError = (_imageFile == null);
            });
            if (showImageSelectError) {
              ToastMessageUtil.showToast(
                  "Por favor, ingresa tu imagen de perfil", context);
              return;
            }

            if (formKey.currentState?.validate() ?? false) {
              //createa GUser instance
              logger.f("testing button createa account");
              // Procesar creación de cuenta
              await authViewModel.createAccount(context);
            }
          },
          child: !authViewModel.loading
              ? const Text("Crear cuenta")
              : const CircularProgressIndicator(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            thumbVisibility: true, // Muestra siempre la barra de scroll
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _showImagePickerSheet(context),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary
                                      .withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.purple,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : const AssetImage(
                                          'assets/img/default_profile.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        if (showImageSelectError)
                          const Text(
                            "Por favor, seleccione una imagen",
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                hintText: 'Nombre',
                                textEditingController:
                                    authViewModel.nameController,
                                validator: (p0) {
                                  p0 = p0?.trim();
                                  authViewModel.nameController.text =
                                      authViewModel.nameController.text.trim();
                                  if (p0 == null || p0.isEmpty) {
                                    return 'Por favor, ingrese su nombre';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                hintText: 'Apellido',
                                textEditingController:
                                    authViewModel.lastnameController,
                                validator: (p0) {
                                  p0 = p0?.trim();
                                  authViewModel.lastnameController.text =
                                      authViewModel.lastnameController.text
                                          .trim();
                                  if (p0 == null || p0.isEmpty) {
                                    return 'Por favor, ingrese su apellido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: "Correo electrónico",
                          textEditingController: authViewModel.emailController,
                          validator: (value) {
                            value = value?.trim();

                            //call TRIM all
                            //valdiate all
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su correo electrónico'; // Required validation
                            }
                            // Email format validation
                            const emailPattern =
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            final emailRegex = RegExp(emailPattern);
                            if (!emailRegex.hasMatch(value)) {
                              return 'Por favor, ingrese un correo electrónico válido';
                            }
                            return null; // Return null if validation passes
                          },
                        ),
                        const SizedBox(height: 10),
                        PhoneNumberField(
                          textController: authViewModel.phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un número';
                            } else if (value.length < 9) {
                              return 'El número debe tener al menos 9 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: 'Modelo de vehículo',
                          textEditingController:
                              authViewModel.vehicleModelController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor, ingrese el modelo de vehículo'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: 'Número de disco',
                          textEditingController:
                              authViewModel.taxiCodeController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor, ingrese el número de disco'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: 'Tipo de licencia',
                          textEditingController:
                              authViewModel.licenceTypeController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor, ingrese la licencia'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          hintText: 'Placa',
                          textEditingController: authViewModel.placaController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor, ingrese la placa'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        PasswordTextfield(
                          hintText: "Contraseña",
                          textEditingController:
                              authViewModel.passwordController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor ingresa una contraseña'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        PasswordTextfield(
                          hintText: "Repetir la contraseña",
                          textEditingController:
                              authViewModel.passwordConfirmController,
                          validator: (p0) => p0 == null || p0.isEmpty
                              ? 'Por favor ingresa una contraseña'
                              : null,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

//
  void _showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Text("Selecciona una fuente",
                style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
          ],
        );
      },
    );
  }

  //Pick image from diferent sources
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedfile = await picker.pickImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _imageFile = File(pickedfile.path);
      });
    }
  }
}
