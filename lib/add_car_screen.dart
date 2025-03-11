import 'dart:io';

import 'package:carlog/car_details_model.dart';
import 'package:carlog/services/azure_document_service.dart';
import 'package:carlog/widgets/form_section.dart';
import 'package:carlog/widgets/form_text_field.dart';
import 'package:carlog/widgets/image_picker_section.dart';
import 'package:carlog/widgets/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class CarScreenType {
  const CarScreenType();
}

class Add extends CarScreenType {
  Add();
}

class Edit extends CarScreenType {
  Edit(this.car);
  final CarDetails car;
}

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({required this.onCarUpdate, required this.type, super.key});

  final VoidCallback onCarUpdate;
  final CarScreenType type;

  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _chassisController = TextEditingController();
  final TextEditingController _engineDisplacementController = TextEditingController();
  final TextEditingController _enginePowerController = TextEditingController();
  final TextEditingController _typeOfFuelController = TextEditingController();
  final TextEditingController _repairController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.type is Edit) {
      final car = (widget.type as Edit).car;
      _ownerController.text = car.ownerName;
      _licenseController.text = car.licensePlate ?? '';
      _cityController.text = car.city ?? '';
      _addressController.text = car.address ?? '';
      _makeController.text = car.make ?? '';
      _modelController.text = car.model ?? '';
      _chassisController.text = car.chassisNumber ?? '';
      _engineDisplacementController.text = car.engineDisplacement ?? '';
      _enginePowerController.text = car.enginePower ?? '';
      _typeOfFuelController.text = car.typeOfFuel ?? '';
      _repairController.text = car.repairNotes ?? '';
    }
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _licenseController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _chassisController.dispose();
    _engineDisplacementController.dispose();
    _enginePowerController.dispose();
    _typeOfFuelController.dispose();
    _repairController.dispose();
    super.dispose();
  }

  void _fillFormFromRegistration(CarDetails carDetails) {
    if (carDetails.make?.isNotEmpty ?? false) {
      _makeController.text = carDetails.make!;
    }
    if (carDetails.model?.isNotEmpty ?? false) {
      _modelController.text = carDetails.model!;
    }
    if (carDetails.chassisNumber?.isNotEmpty ?? false) {
      _chassisController.text = carDetails.chassisNumber!;
    }
    if (carDetails.engineDisplacement?.isNotEmpty ?? false) {
      _engineDisplacementController.text = carDetails.engineDisplacement!;
    }
    if (carDetails.enginePower?.isNotEmpty ?? false) {
      _enginePowerController.text = carDetails.enginePower!;
    }
    if (carDetails.typeOfFuel?.isNotEmpty ?? false) {
      _typeOfFuelController.text = carDetails.typeOfFuel!;
    }
    if (carDetails.licensePlate?.isNotEmpty ?? false) {
      _licenseController.text = carDetails.licensePlate!;
    }
    if (carDetails.ownerName.isNotEmpty) {
      _ownerController.text = carDetails.ownerName;
    }
    if (carDetails.city?.isNotEmpty ?? false) {
      _cityController.text = carDetails.city!;
    }
    if (carDetails.address?.isNotEmpty ?? false) {
      _addressController.text = carDetails.address!;
    }
  }

  Future<void> scanDriverLicense(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image == null) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _image = File(image.path);
      });

      if (!context.mounted) return;

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingOverlay(
          message: 'Skeniram saobraćajnu dozvolu...\nMolimo sačekajte',
        ),
      );

      final azureService = AzureDocumentService.getInstance();
      final result = await azureService.analyzeDriverLicense(File(image.path));
      final carDetails = azureService.extractDriverLicenseFields(result);
      _fillFormFromRegistration(carDetails);

      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saobraćajna dozvola je uspešno skenirana')),
      );
    } catch (e) {
      if (!context.mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom skeniranja dokumenta: $e')),
      );
    }
  }

  void _doEdit(CarScreenType type) {
    switch (type) {
      case Add():
        _editCar(null);
      case Edit():
        _editCar((type).car);
    }
  }

  void _editCar(CarDetails? car) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    DocumentReference<Map<String, dynamic>> carDoc;

    if (car == null) {
      carDoc = FirebaseFirestore.instance.collection('cars').doc();
    } else {
      carDoc = FirebaseFirestore.instance.collection('cars').doc(car.id);
    }

    final updatedCar = CarDetails(
      id: carDoc.id,
      ownerName: _ownerController.text.trim(),
      licensePlate: _licenseController.text.trim(),
      city: _cityController.text.trim(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      address: _addressController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      chassisNumber: _chassisController.text.trim(),
      engineDisplacement: _engineDisplacementController.text.trim(),
      enginePower: _enginePowerController.text.trim(),
      typeOfFuel: _typeOfFuelController.text.trim(),
      repairNotes: _repairController.text.trim(),
    );

    if (car == null) {
      FirebaseFirestore.instance.collection('cars').add(updatedCar.toFirestore());
    } else {
      carDoc.update(updatedCar.toFirestore());
    }
    widget.onCarUpdate();
    Navigator.pop(context);
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final carDetails = CarDetails(
        id: widget.type is Edit ? (widget.type as Edit).car.id : '',
        ownerName: _ownerController.text,
        licensePlate: _licenseController.text,
        city: _cityController.text,
        address: _addressController.text,
        make: _makeController.text,
        model: _modelController.text,
        chassisNumber: _chassisController.text,
        engineDisplacement: _engineDisplacementController.text,
        enginePower: _enginePowerController.text,
        typeOfFuel: _typeOfFuelController.text,
        repairNotes: _repairController.text,
        userId: userId,
      );

      if (widget.type is Add) {
        await FirebaseFirestore.instance.collection('cars').add(carDetails.toFirestore());
      } else if (widget.type is Edit) {
        await FirebaseFirestore.instance.collection('cars').doc(carDetails.id).update(carDetails.toFirestore());
      }

      if (mounted) {
        widget.onCarUpdate();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do greške prilikom čuvanja podataka')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type is Add ? 'Dodaj auto' : 'Izmeni auto',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImagePickerSection(
                image: _image,
                onCameraPressed: () => scanDriverLicense(context, ImageSource.camera),
                onGalleryPressed: () => scanDriverLicense(context, ImageSource.gallery),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormSection(
                      title: 'Podaci o vlasniku',
                      fields: [
                        FormTextField(
                          controller: _ownerController,
                          label: 'Ime vlasnika',
                          icon: Icons.person,
                          validator: (value) => value!.isEmpty ? 'Unesi ime vlasnika' : null,
                        ),
                        FormTextField(
                          controller: _cityController,
                          label: 'Grad',
                          icon: Icons.location_city,
                        ),
                        FormTextField(
                          controller: _addressController,
                          label: 'Adresa',
                          icon: Icons.home,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FormSection(
                      title: 'Podaci o vozilu',
                      fields: [
                        FormTextField(
                          controller: _makeController,
                          label: 'Marka',
                          icon: Icons.directions_car,
                        ),
                        FormTextField(
                          controller: _modelController,
                          label: 'Model',
                          icon: Icons.car_repair,
                        ),
                        FormTextField(
                          controller: _chassisController,
                          label: 'Broj šasije',
                          icon: Icons.numbers,
                        ),
                        FormTextField(
                          controller: _engineDisplacementController,
                          label: 'Zapremina motora',
                          icon: Icons.speed,
                        ),
                        FormTextField(
                          controller: _enginePowerController,
                          label: 'Snaga motora',
                          icon: Icons.power,
                        ),
                        FormTextField(
                          controller: _typeOfFuelController,
                          label: 'Vrsta goriva',
                          icon: Icons.local_gas_station,
                        ),
                        FormTextField(
                          controller: _licenseController,
                          label: 'Registracione tablice',
                          icon: Icons.badge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FormSection(
                      title: 'Dodatne informacije',
                      fields: [
                        FormTextField(
                          controller: _repairController,
                          label: 'Napomene',
                          icon: Icons.note_add,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _saveCar(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAČUVAJ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
