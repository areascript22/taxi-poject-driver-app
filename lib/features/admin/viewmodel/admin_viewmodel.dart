import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/admin/services/admin_service.dart';
import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';

class AdminViewModel extends ChangeNotifier {
  final logger = Logger();
  bool _loading = false;
  bool _isSearching = false;
  List<GUser> _documents = [];
  List<GUser> _searchResults = [];
  //
  //For EditProfilePage
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController vehicleModelController = TextEditingController();
  TextEditingController taxiCodeController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController registrationNumberController = TextEditingController();
  bool _showImageSelectError = false;

  //getters
  bool get loading => _loading;
  bool get isSearching => _isSearching;
  List<GUser> get documents => _documents;
  List<GUser> get searchResults => _searchResults;
  bool get showImageSelectError => _showImageSelectError;
  //setters
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set isSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  set documents(List<GUser> value) {
    _documents = value;
    notifyListeners();
  }

  set searchResults(List<GUser> value) {
    _searchResults = value;
    notifyListeners();
  }

  set showImageSelectError(bool value) {
    _showImageSelectError = value;
    notifyListeners();
  }

  //Add documents
  void addDocuments(List<QueryDocumentSnapshot<Object?>> docs) {
    for (var element in docs) {
      final data = element.data() as Map<String, dynamic>;
      final driver = GUser.fromMap(data, id: element.id);
      documents.add(driver);
    }

    notifyListeners();
  }

  //Add searchResults
  void addsearchResults(List<QueryDocumentSnapshot<Object?>> docs) {
    for (var element in docs) {
      final data = element.data() as Map<String, dynamic>;
      final driver = GUser.fromMap(data, id: element.id);
      searchResults.add(driver);
    }

    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  void clearDocs() {
    _documents.clear;
    notifyListeners();
  }

  //give and remove access to the driver
  Future<void> updateAccess1(GUser driver, String access, BuildContext context,
      int indexInArray, SharedProvider sharedVM) async {
    loading = true;
    //Check if user has permissions oover another user
    final currentUser = sharedVM.driver!;
    if (!currentUser.canManageUser(driver)) {
      ToastMessageUtil.showToast(
          "No se puede realizar esta operación", context);
      loading = false;
      return;
    }
    String documentId = driver.id!;
    final response =
        await AdminService.updateAccess(documentId: documentId, access: access);
    if (response) {
      //Update driver data locally
      if (isSearching) {
        final tempDriver = searchResults[indexInArray].toMap();
        tempDriver['access'] = access;
        searchResults[indexInArray] = GUser.fromMap(tempDriver, id: documentId);
        notifyListeners();
      } else {
        final tempDriver = documents[indexInArray].toMap();
        tempDriver['access'] = access;
        documents[indexInArray] = GUser.fromMap(tempDriver, id: documentId);
        notifyListeners();
      }
      if (context.mounted) {
        ToastMessageUtil.showToast(
          "Acceso ${access == Access.granted ? "concedido" : "denegado"}",
          context,
        );
      }
    } else {
      if (context.mounted) {
        ToastMessageUtil.showToast(
          "No se pudo ${access == Access.granted ? "quitar" : "asignar"} el acceso",
          context,
        );
      }
    }
    loading = false;
  }

  //Update one or many user fields
  void updateDriverData(
      GlobalKey<FormState> formKey,
      BuildContext context,
      GUser driverModel,
      File? imageFile,
      SharedProvider sharedProvider,
      int indexInArray) async {
    FocusScope.of(context).unfocus();
    loading = false;
    //check if there is an image selected, otherwise we return
    if (imageFile == null && driverModel.profilePicture.isEmpty) {
      showImageSelectError = true;
      logger.i("imagen $imageFile   ${driverModel.profilePicture}");
    } else {
      logger.i("No imagen $imageFile  ${driverModel.profilePicture}");
      showImageSelectError = false;
    }

    if (showImageSelectError) {
      return;
    }
    //Check driver Id
    if (driverModel.id == null) {
      logger.e("No drivre id to update");
      return;
    }
    //Check form fields
    if (formKey.currentState?.validate() ?? false) {
      loading = true;
      //upnload image

      String? profilePicture = '';
      if (imageFile != null) {
        //Upload new image
        profilePicture = await AdminService.uploadImage(
            imageFile, FirebaseAuth.instance.currentUser!.uid);

        // sharedProvider.passenger!.profilePicture = profilePicture!;
      }

      //add data to update
      Map<String, dynamic> driverNewValues = {};
      Map<String, dynamic> vehicleNewValues = {};

      if (profilePicture!.isNotEmpty) {
        driverNewValues['profilePicture'] = profilePicture;
      }
      if (nameController.text != driverModel.name) {
        driverNewValues['name'] = nameController.text;
      }
      if (lastnameController.text != driverModel.lastName) {
        driverNewValues['lastName'] = lastnameController.text;
      }
      if (emailController.text != driverModel.email) {
        driverNewValues['email'] = emailController.text;
      }
      if (phoneController.text != driverModel.phone) {
        driverNewValues['phone'] = phoneController.text;
      }
      if (vehicleModelController.text != driverModel.vehicle?.model) {
        vehicleNewValues['model'] = vehicleModelController.text;
      }
      if (taxiCodeController.text != driverModel.vehicle?.taxiCode) {
        vehicleNewValues['taxiCode'] = taxiCodeController.text;
      }
      if (licenseController.text != driverModel.vehicle?.license) {
        vehicleNewValues['license'] = licenseController.text;
      }
      if (registrationNumberController.text !=
          driverModel.vehicle?.carRegistrationNumber) {
        vehicleNewValues["carRegistrationNumber"] =
            registrationNumberController.text;
      }

      // if(vehicleNewValues.isNotEmpty){
      // driverNewValues['vehicle'] = vehicleNewValues;
      // }

      logger.e("Values to update: ${driverNewValues.isEmpty}");

      //Update data in firestore
      bool dataUpdated = await AdminService.updatePassengerDataInFirestore(
          driverNewValues, vehicleNewValues, driverModel.id!);

      //Navigato to Map Page
      if (dataUpdated) {
        //Update local model
        //Update driver data locally
        if (isSearching) {
          driverNewValues['vehicle'] = vehicleNewValues;
          final tempDriver =
              searchResults[indexInArray].copyWithMap(driverNewValues);

          searchResults[indexInArray] = tempDriver;

          notifyListeners();
        } else {
          driverNewValues['vehicle'] = vehicleNewValues;
          final tempDriver =
              documents[indexInArray].copyWithMap(driverNewValues);
          logger.f("Temp Driver:  ${tempDriver.toMap()}");
          documents[indexInArray] = tempDriver;
          notifyListeners();
        }
        if (context.mounted) {
          ToastMessageUtil.showToast('Datos actualizados', context);
          Navigator.pop(context);
        }
      }

      loading = false;
    }
  }

  //Delete account
  Future<String?> deleteDriverAccount(GUser driverToDelete,
      BuildContext context, SharedProvider sharedVM) async {
    loading = true;
    //Check if user has permissions oover another user
    final currentUser = sharedVM.driver!;
    if (!currentUser.canManageUser(driverToDelete)) {
      // ToastMessageUtil.showToast(
      //     "No se puede realizar esta operación", context);
      loading = false;
      return "No se puede realizar esta operación";
    }

    final respones =
        await AdminService.deleteUser(userIdToDelete: driverToDelete.id!);
    if (respones is Succes) {
      // if (context.mounted) {
      //   ToastMessageUtil.showToast(
      //       "${driverToDelete.name} eliminado correctamente", context);
      // }

      if (isSearching) {
        searchResults.remove(driverToDelete);
        notifyListeners();
      } else {
        documents.remove(driverToDelete);
        notifyListeners();
      }
      loading = false;
      return null;
    } else {
      final responesTemp = respones as Failure;
      loading = false;
      return responesTemp.errorResponse;
    }
  }
}
