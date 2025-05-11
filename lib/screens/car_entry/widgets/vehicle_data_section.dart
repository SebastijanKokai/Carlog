import 'package:flutter/material.dart';
import 'package:carlog/screens/car_entry/car_entry_form_controller.dart';
import 'package:carlog/screens/car_entry/widgets/car_form_section.dart';
import 'package:carlog/widgets/form/form_text_field.dart';

class VehicleDataSection extends StatelessWidget {
  final CarEntryFormController formController;

  const VehicleDataSection({
    super.key,
    required this.formController,
  });

  @override
  Widget build(BuildContext context) {
    return CarFormSection(
      title: 'Podaci o vozilu',
      fields: [
        FormTextField(
          controller: formController.makeController,
          label: 'Marka',
          icon: Icons.directions_car,
          validator: formController.validateMake,
        ),
        FormTextField(
          controller: formController.modelController,
          label: 'Model',
          icon: Icons.car_repair,
          validator: formController.validateModel,
        ),
        FormTextField(
          controller: formController.chassisController,
          label: 'Broj šasije',
          icon: Icons.numbers,
        ),
        FormTextField(
          controller: formController.engineDisplacementController,
          label: 'Zapremina motora',
          icon: Icons.speed,
        ),
        FormTextField(
          controller: formController.enginePowerController,
          label: 'Snaga motora',
          icon: Icons.power,
        ),
        FormTextField(
          controller: formController.typeOfFuelController,
          label: 'Vrsta goriva',
          icon: Icons.local_gas_station,
        ),
        FormTextField(
          controller: formController.licenseController,
          label: 'Registracione tablice',
          icon: Icons.badge,
          validator: formController.validateLicense,
        ),
      ],
    );
  }
}
