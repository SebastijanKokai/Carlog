import 'dart:io';

import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/screens/car_entry/car_entry_form_controller.dart';
import 'package:carlog/screens/car_entry/widgets/additional_info_section.dart';
import 'package:carlog/screens/car_entry/widgets/owner_data_section.dart';
import 'package:carlog/screens/car_entry/widgets/vehicle_data_section.dart';
import 'package:carlog/services/azure_document_service.dart';
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

class CarEntryScreen extends StatefulWidget {
  const CarEntryScreen({required this.onCarUpdate, required this.type, super.key});

  final VoidCallback onCarUpdate;
  final CarScreenType type;

  @override
  CarEntryScreenState createState() => CarEntryScreenState();
}

class CarEntryScreenState extends State<CarEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CarEntryFormController _formController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _formController = CarEntryFormController();
    if (widget.type is Edit) {
      _formController.fillFromCarDetails((widget.type as Edit).car);
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
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
      _formController.fillFromRegistration(carDetails);

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

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final carDetails = _formController.getCurrentFormData(
        userId,
        id: widget.type is Edit ? (widget.type as Edit).car.id : null,
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
                    OwnerDataSection(formController: _formController),
                    const SizedBox(height: 24),
                    VehicleDataSection(formController: _formController),
                    const SizedBox(height: 24),
                    AdditionalInfoSection(formController: _formController),
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
