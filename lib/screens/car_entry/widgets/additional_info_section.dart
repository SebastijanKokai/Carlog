import 'package:flutter/material.dart';
import 'package:carlog/screens/car_entry/car_entry_form_controller.dart';
import 'package:carlog/screens/car_entry/widgets/car_form_section.dart';
import 'package:carlog/widgets/form/form_text_field.dart';

class AdditionalInfoSection extends StatelessWidget {
  final CarEntryFormController formController;

  const AdditionalInfoSection({
    super.key,
    required this.formController,
  });

  @override
  Widget build(BuildContext context) {
    return CarFormSection(
      title: 'Dodatne informacije',
      fields: [
        FormTextField(
          controller: formController.repairController,
          label: 'Napomene',
          icon: Icons.note_add,
          maxLines: 3,
        ),
      ],
    );
  }
}
