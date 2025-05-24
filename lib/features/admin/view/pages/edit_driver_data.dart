import 'dart:io';
import 'package:driver_app/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EditDriverDataPage extends StatefulWidget {
  final GUser driver;
  final int indexInArray;
  const EditDriverDataPage({
    super.key,
    required this.driver,
    required this.indexInArray,
  });

  @override
  State<EditDriverDataPage> createState() => _EditDriverDataPageState();
}

class _EditDriverDataPageState extends State<EditDriverDataPage> {
  final Logger logger = Logger();
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  File? _imageFile;
//  bool showImageSelectError = false;
  final formKey = GlobalKey<FormState>();
  late AdminViewModel adminVMToDispose;

  // bool isThereChangesToSave = false;
  GUser? driverModelTemp;
  @override
  void initState() {
    super.initState();
    logger.f("EDIT DATA INIT STATE");
    _initValues();
  }

  void _initValues() {
    final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
    adminVMToDispose = adminViewModel;
    driverModelTemp = widget.driver;
    adminViewModel.nameController.text = driverModelTemp!.name;
    adminViewModel.lastnameController.text = driverModelTemp!.lastName! ?? '';
    adminViewModel.phoneController.text = driverModelTemp!.phone;
    adminViewModel.emailController.text = driverModelTemp!.email ?? '';
    adminViewModel.vehicleModelController.text =
        driverModelTemp!.vehicle?.model ?? '';
    adminViewModel.taxiCodeController.text =
        driverModelTemp!.vehicle?.taxiCode ?? '';
    adminViewModel.licenseController.text =
        driverModelTemp!.vehicle?.license ?? '';
    adminViewModel.registrationNumberController.text =
        driverModelTemp!.vehicle?.carRegistrationNumber ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    adminVMToDispose.documents.clear();
    adminVMToDispose.searchResults.clear();
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Profile image
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                "Selecciona una fuente",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
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
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Eliminar foto',
                                    style: TextStyle(color: Colors.red),
                                  ),
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
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? ClipOval(
                              child: driverModelTemp!.profilePicture.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      placeholder: 'assets/img/no_image.png',
                                      image: driverModelTemp!.profilePicture,
                                      fadeInDuration:
                                          const Duration(milliseconds: 50),
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 150,
                                    )
                                  : Image.asset(
                                      'assets/img/default_profile.png',
                                      fit: BoxFit.cover,
                                      width: 155,
                                      height: 155,
                                    ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  if (adminViewModel.showImageSelectError)
                    const Text(
                      "Por favor, seleccione una imagen",
                      style: TextStyle(color: Colors.red),
                    ),

                  //Personal info
                  //Name
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: 'Nombre',
                          textEditingController: adminViewModel.nameController,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Por favor, ingrese su nombre'; // Required validation
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: CustomTextField(
                          hintText: 'Apellido',
                          textEditingController:
                              adminViewModel.lastnameController,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Por favor, ingrese su apellido'; // Required validation
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Email",
                    textEditingController: adminViewModel.emailController,
                    enabled: false,
                    validator: (p0) {
                      if (p0 != null && p0.isNotEmpty) {
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(p0)) {
                          return 'Enter a valid email';
                        }
                      }
                      return null; // No error if empty (optional field)
                    },
                  ),

                  //Phone
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Phone",
                    textEditingController: adminViewModel.phoneController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Por favor, ingrese el número de celular'; // Required validation
                      }
                      return null;
                    },
                  ),

                  //Vehicle model
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Modelo del vehículo",
                    textEditingController:
                        adminViewModel.vehicleModelController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Por favor, ingrese el modelo del vehículo'; // Required validation
                      }
                      return null;
                    },
                  ),

                  //Taxi code and license
                  //Name
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: 'Código de taxi',
                          textEditingController:
                              adminViewModel.taxiCodeController,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Por favor, ingrese el código'; // Required validation
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: CustomTextField(
                          hintText: 'Licencia',
                          textEditingController:
                              adminViewModel.licenseController,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Por favor, ingrese la licencia'; // Required validation
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  //Vehicle registration number
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Placa",
                    textEditingController:
                        adminViewModel.registrationNumberController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Por favor, ingrese la placa del veículo'; // Required validation
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CustomElevatedButton(
                      onTap: () => adminViewModel.updateDriverData(
                        formKey,
                        context,
                        driverModelTemp!,
                        _imageFile,
                        sharedProvider,
                        widget.indexInArray,
                      ),
                      child: !adminViewModel.loading
                          ? const Text("Guardar")
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ],
              )),
        ),
      ),
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
