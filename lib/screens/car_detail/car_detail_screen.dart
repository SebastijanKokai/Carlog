import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carlog/constants/firebase_constants.dart';
import 'package:carlog/extensions/firestore_extensions.dart';
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
      body: FutureBuilder(
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

          var carData = snapshot.data!;

          final ownerName = carData.getString(FirebaseConstants.ownerName);
          final licensePlate = carData.getString(FirebaseConstants.licensePlate);
          final city = carData.getString(FirebaseConstants.city);
          final address = carData.getString(FirebaseConstants.address);
          final make = carData.getString(FirebaseConstants.make);
          final model = carData.getString(FirebaseConstants.model);
          final chassisNumber = carData.getString(FirebaseConstants.chassisNumber);
          final engineDisplacement = carData.getString(FirebaseConstants.engineDisplacement);
          final enginePower = carData.getString(FirebaseConstants.enginePower);
          final typeOfFuel = carData.getString(FirebaseConstants.typeOfFuel);
          final repairNotes = carData.getString(FirebaseConstants.repairNotes);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CarHeader(
                  make: make,
                  model: model,
                  licensePlate: licensePlate,
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
                            value: ownerName,
                          ),
                          DetailField(
                            icon: Icons.location_city,
                            label: 'Grad',
                            value: city,
                          ),
                          DetailField(
                            icon: Icons.home,
                            label: 'Adresa',
                            value: address,
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
                            value: make,
                          ),
                          DetailField(
                            icon: Icons.car_repair,
                            label: 'Model',
                            value: model,
                          ),
                          DetailField(
                            icon: Icons.numbers,
                            label: 'Broj šasije',
                            value: chassisNumber,
                          ),
                          DetailField(
                            icon: Icons.speed,
                            label: 'Zapremina motora',
                            value: engineDisplacement,
                          ),
                          DetailField(
                            icon: Icons.power,
                            label: 'Snaga motora',
                            value: enginePower,
                          ),
                          DetailField(
                            icon: Icons.local_gas_station,
                            label: 'Tip goriva',
                            value: typeOfFuel,
                          ),
                          DetailField(
                            icon: Icons.badge,
                            label: 'Registarske tablice',
                            value: licensePlate,
                          ),
                        ],
                      ),
                      if (repairNotes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        InfoSection(
                          title: 'Napomene',
                          children: [
                            DetailField(
                              icon: Icons.note,
                              label: 'Napomene o popravkama',
                              value: repairNotes,
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
