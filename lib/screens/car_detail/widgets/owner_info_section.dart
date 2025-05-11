import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/screens/car_detail/widgets/info_section.dart';
import 'package:carlog/screens/car_detail/widgets/detail_field.dart';

class OwnerInfoSection extends StatelessWidget {
  final CarDetails car;

  const OwnerInfoSection({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Podaci o vlasniku',
      children: [
        DetailField(
          icon: Icons.person,
          label: 'Ime vlasnika',
          value: car.ownerName,
        ),
        DetailField(
          icon: Icons.location_city,
          label: 'Grad',
          value: car.city ?? '',
        ),
        DetailField(
          icon: Icons.home,
          label: 'Adresa',
          value: car.address ?? '',
        ),
      ],
    );
  }
}
