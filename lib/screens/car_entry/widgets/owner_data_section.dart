import 'package:flutter/material.dart';
import 'package:carlog/screens/car_entry/car_entry_form_controller.dart';
import 'package:carlog/screens/car_entry/widgets/car_form_section.dart';
import 'package:carlog/widgets/form/form_text_field.dart';

class OwnerDataSection extends StatelessWidget {
  final CarEntryFormController formController;

  const OwnerDataSection({
    super.key,
    required this.formController,
  });

  @override
  Widget build(BuildContext context) {
    return CarFormSection(
      title: 'Podaci o vlasniku',
      fields: [
        FormTextField(
          controller: formController.ownerController,
          label: 'Ime vlasnika',
          icon: Icons.person,
          validator: formController.validateOwner,
        ),
        FormTextField(
          controller: formController.cityController,
          label: 'Grad',
          icon: Icons.location_city,
        ),
        FormTextField(
          controller: formController.addressController,
          label: 'Adresa',
          icon: Icons.home,
        ),
      ],
    );
  }
}
