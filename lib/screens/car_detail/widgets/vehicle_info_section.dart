import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/screens/car_detail/widgets/info_section.dart';
import 'package:carlog/screens/car_detail/widgets/detail_field.dart';

class VehicleInfoSection extends StatelessWidget {
  final CarDetails car;

  const VehicleInfoSection({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return InfoSection(
      title: 'Podaci o vozilu',
      children: [
        DetailField(
          icon: Icons.directions_car,
          label: 'Marka',
          value: car.make ?? '',
        ),
        DetailField(
          icon: Icons.car_repair,
          label: 'Model',
          value: car.model ?? '',
        ),
        DetailField(
          icon: Icons.numbers,
          label: 'Broj šasije',
          value: car.chassisNumber ?? '',
        ),
        DetailField(
          icon: Icons.speed,
          label: 'Zapremina motora',
          value: car.engineDisplacement ?? '',
        ),
        DetailField(
          icon: Icons.power,
          label: 'Snaga motora',
          value: car.enginePower ?? '',
        ),
        DetailField(
          icon: Icons.local_gas_station,
          label: 'Tip goriva',
          value: car.typeOfFuel ?? '',
        ),
        DetailField(
          icon: Icons.badge,
          label: 'Registarske tablice',
          value: car.licensePlate ?? '',
        ),
      ],
    );
  }
}
