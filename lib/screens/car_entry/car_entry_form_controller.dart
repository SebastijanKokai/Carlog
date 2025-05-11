import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';

class CarEntryFormController {
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController engineDisplacementController = TextEditingController();
  final TextEditingController enginePowerController = TextEditingController();
  final TextEditingController typeOfFuelController = TextEditingController();
  final TextEditingController repairController = TextEditingController();

  String? validateOwner(String? value) => value?.isEmpty ?? true ? 'Unesi ime vlasnika' : null;
  String? validateLicense(String? value) => value?.isEmpty ?? true ? 'Unesi registracione tablice' : null;
  String? validateMake(String? value) => value?.isEmpty ?? true ? 'Unesi marku vozila' : null;
  String? validateModel(String? value) => value?.isEmpty ?? true ? 'Unesi model vozila' : null;

  void fillFromCarDetails(CarDetails car) {
    ownerController.text = car.ownerName;
    licenseController.text = car.licensePlate ?? '';
    cityController.text = car.city ?? '';
    addressController.text = car.address ?? '';
    makeController.text = car.make ?? '';
    modelController.text = car.model ?? '';
    chassisController.text = car.chassisNumber ?? '';
    engineDisplacementController.text = car.engineDisplacement ?? '';
    enginePowerController.text = car.enginePower ?? '';
    typeOfFuelController.text = car.typeOfFuel ?? '';
    repairController.text = car.repairNotes ?? '';
  }

  void fillFromRegistration(CarDetails carDetails) {
    if (carDetails.make?.isNotEmpty ?? false) {
      makeController.text = carDetails.make!;
    }
    if (carDetails.model?.isNotEmpty ?? false) {
      modelController.text = carDetails.model!;
    }
    if (carDetails.chassisNumber?.isNotEmpty ?? false) {
      chassisController.text = carDetails.chassisNumber!;
    }
    if (carDetails.engineDisplacement?.isNotEmpty ?? false) {
      engineDisplacementController.text = carDetails.engineDisplacement!;
    }
    if (carDetails.enginePower?.isNotEmpty ?? false) {
      enginePowerController.text = carDetails.enginePower!;
    }
    if (carDetails.typeOfFuel?.isNotEmpty ?? false) {
      typeOfFuelController.text = carDetails.typeOfFuel!;
    }
    if (carDetails.licensePlate?.isNotEmpty ?? false) {
      licenseController.text = carDetails.licensePlate!;
    }
    if (carDetails.ownerName.isNotEmpty) {
      ownerController.text = carDetails.ownerName;
    }
    if (carDetails.city?.isNotEmpty ?? false) {
      cityController.text = carDetails.city!;
    }
    if (carDetails.address?.isNotEmpty ?? false) {
      addressController.text = carDetails.address!;
    }
  }

  CarDetails getCurrentFormData({String? id}) {
    return CarDetails(
      id: id ?? '',
      ownerName: ownerController.text,
      licensePlate: licenseController.text,
      city: cityController.text,
      address: addressController.text,
      make: makeController.text,
      model: modelController.text,
      chassisNumber: chassisController.text,
      engineDisplacement: engineDisplacementController.text,
      enginePower: enginePowerController.text,
      typeOfFuel: typeOfFuelController.text,
      repairNotes: repairController.text,
      userId: '',
    );
  }

  void dispose() {
    ownerController.dispose();
    licenseController.dispose();
    cityController.dispose();
    addressController.dispose();
    makeController.dispose();
    modelController.dispose();
    chassisController.dispose();
    engineDisplacementController.dispose();
    enginePowerController.dispose();
    typeOfFuelController.dispose();
    repairController.dispose();
  }
}
