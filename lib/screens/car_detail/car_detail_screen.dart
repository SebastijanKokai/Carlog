import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/services/car_service.dart';
import 'package:carlog/screens/car_detail/widgets/car_header.dart';
import 'package:carlog/screens/car_detail/widgets/info_section.dart';
import 'package:carlog/screens/car_detail/widgets/detail_field.dart';

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
                      InfoSection(
                        title: 'Podaci o vlasniku',
                        children: [
                          DetailField(
                            icon: Icons.person,
                            label: 'Ime vlasnika',
                            value: carDetails.ownerName,
                          ),
                          DetailField(
                            icon: Icons.location_city,
                            label: 'Grad',
                            value: carDetails.city ?? '',
                          ),
                          DetailField(
                            icon: Icons.home,
                            label: 'Adresa',
                            value: carDetails.address ?? '',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      InfoSection(
                        title: 'Podaci o vozilu',
                        children: [
                          DetailField(
                            icon: Icons.directions_car,
                            label: 'Marka',
                            value: carDetails.make ?? '',
                          ),
                          DetailField(
                            icon: Icons.car_repair,
                            label: 'Model',
                            value: carDetails.model ?? '',
                          ),
                          DetailField(
                            icon: Icons.numbers,
                            label: 'Broj šasije',
                            value: carDetails.chassisNumber ?? '',
                          ),
                          DetailField(
                            icon: Icons.speed,
                            label: 'Zapremina motora',
                            value: carDetails.engineDisplacement ?? '',
                          ),
                          DetailField(
                            icon: Icons.power,
                            label: 'Snaga motora',
                            value: carDetails.enginePower ?? '',
                          ),
                          DetailField(
                            icon: Icons.local_gas_station,
                            label: 'Tip goriva',
                            value: carDetails.typeOfFuel ?? '',
                          ),
                          DetailField(
                            icon: Icons.badge,
                            label: 'Registarske tablice',
                            value: carDetails.licensePlate ?? '',
                          ),
                        ],
                      ),
                      if (carDetails.repairNotes?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 24),
                        InfoSection(
                          title: 'Napomene',
                          children: [
                            DetailField(
                              icon: Icons.note,
                              label: 'Napomene o popravkama',
                              value: carDetails.repairNotes ?? '',
                              isMultiline: true,
                            ),
                          ],
                        ),
                      ],
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
