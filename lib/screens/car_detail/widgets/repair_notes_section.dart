import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/screens/car_detail/widgets/info_section.dart';
import 'package:carlog/screens/car_detail/widgets/detail_field.dart';

class RepairNotesSection extends StatelessWidget {
  final CarDetails car;

  const RepairNotesSection({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    if (car.repairNotes?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return InfoSection(
      title: 'Napomene',
      children: [
        DetailField(
          icon: Icons.note,
          label: 'Napomene o popravkama',
          value: car.repairNotes ?? '',
          isMultiline: true,
        ),
      ],
    );
  }
}
