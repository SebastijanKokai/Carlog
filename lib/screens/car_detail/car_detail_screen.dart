import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/services/car_service.dart';
import 'package:carlog/screens/car_detail/widgets/car_header.dart';
import 'package:carlog/screens/car_detail/widgets/owner_info_section.dart';
import 'package:carlog/screens/car_detail/widgets/vehicle_info_section.dart';
import 'package:carlog/screens/car_detail/widgets/repair_notes_section.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  final CarService _carService = CarService();

  CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji automobila'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _carService.getCarDetails(carId),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Došlo je do greške: ${snapshot.error}'),
            );
          }

          final carDetails = CarDetails.fromFirestore(
            snapshot.data! as DocumentSnapshot<Map<String, dynamic>>,
            null,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CarHeader(
                  make: carDetails.make ?? '',
                  model: carDetails.model ?? '',
                  licensePlate: carDetails.licensePlate ?? '',
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OwnerInfoSection(car: carDetails),
                      const SizedBox(height: 24),
                      VehicleInfoSection(car: carDetails),
                      const SizedBox(height: 24),
                      RepairNotesSection(car: carDetails),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
