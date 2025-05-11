import 'dart:io';

import 'package:carlog/screens/car_entry/car_entry_form_controller.dart';
import 'package:carlog/screens/car_entry/car_screen_type.dart';
import 'package:carlog/screens/car_entry/widgets/additional_info_section.dart';
import 'package:carlog/screens/car_entry/widgets/owner_data_section.dart';
import 'package:carlog/screens/car_entry/widgets/vehicle_data_section.dart';
import 'package:carlog/services/driver_license_service.dart';
import 'package:carlog/services/car_service.dart';
import 'package:carlog/widgets/image_picker_section.dart';
import 'package:carlog/widgets/loading_overlay.dart';
import 'package:carlog/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _carService = CarService();
  final _driverLicenseService = DriverLicenseService();
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingOverlay(
        message: 'Skeniram saobraćajnu dozvolu...\nMolimo sačekajte',
      ),
    );
  }

  void _popIfPossible() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saobraćajna dozvola je uspešno skenirana')),
    );
  }

  void _showErrorMessage(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška prilikom skeniranja dokumenta: $error')),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final image = await _driverLicenseService.pickImage(source);
      if (image == null) return;

      setState(() => _image = image);
      if (!mounted) return;

      _showLoadingDialog();

      final carDetails = await _driverLicenseService.scanDriverLicense(image);
      _formController.fillFromRegistration(carDetails);

      if (!mounted) return;
      _popIfPossible();
      _showSuccessMessage();
    } catch (e) {
      if (!mounted) return;
      _popIfPossible();
      _showErrorMessage(e);
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final carDetails = _formController.getCurrentFormData(
        id: widget.type is Edit ? (widget.type as Edit).car.id : null,
      );

      await _carService.saveCar(
        carDetails,
        existingId: widget.type is Edit ? (widget.type as Edit).car.id : null,
      );

      if (!mounted) return;

      widget.onCarUpdate();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Došlo je do greške prilikom čuvanja podataka')),
      );
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
                onCameraPressed: () => _handleImageSelection(ImageSource.camera),
                onGalleryPressed: () => _handleImageSelection(ImageSource.gallery),
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
                    SubmitButton(
                      onPressed: () => _saveCar(),
                      text: 'SAČUVAJ',
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
