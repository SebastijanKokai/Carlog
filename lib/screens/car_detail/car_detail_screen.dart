import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji automobila'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('cars').doc(carId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var carData = snapshot.data!;

          final ownerName = carData.data().toString().contains('ownerName') ? carData.get('ownerName') : '';
          final licensePlate = carData.data().toString().contains('licensePlate') ? carData.get('licensePlate') : '';
          final city = carData.data().toString().contains('city') ? carData.get('city') : '';
          final address = carData.data().toString().contains('address') ? carData.get('address') : '';
          final make = carData.data().toString().contains('make') ? carData.get('make') : '';
          final model = carData.data().toString().contains('model') ? carData.get('model') : '';
          final chassisNumber = carData.data().toString().contains('chassisNumber') ? carData.get('chassisNumber') : '';
          final engineDisplacement =
              carData.data().toString().contains('engineDisplacement') ? carData.get('engineDisplacement') : '';
          final enginePower = carData.data().toString().contains('enginePower') ? carData.get('enginePower') : '';
          final typeOfFuel = carData.data().toString().contains('typeOfFuel') ? carData.get('typeOfFuel') : '';
          final repairNotes = carData.data().toString().contains('repairNotes') ? carData.get('repairNotes') : '';

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
                          _DetailField(
                            icon: Icons.person,
                            label: 'Ime vlasnika',
                            value: ownerName,
                          ),
                          _DetailField(
                            icon: Icons.location_city,
                            label: 'Grad',
                            value: city,
                          ),
                          _DetailField(
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
                          _DetailField(
                            icon: Icons.directions_car,
                            label: 'Marka',
                            value: make,
                          ),
                          _DetailField(
                            icon: Icons.car_repair,
                            label: 'Model',
                            value: model,
                          ),
                          _DetailField(
                            icon: Icons.numbers,
                            label: 'Broj šasije',
                            value: chassisNumber,
                          ),
                          _DetailField(
                            icon: Icons.speed,
                            label: 'Zapremina motora',
                            value: engineDisplacement,
                          ),
                          _DetailField(
                            icon: Icons.power,
                            label: 'Snaga motora',
                            value: enginePower,
                          ),
                          _DetailField(
                            icon: Icons.local_gas_station,
                            label: 'Tip goriva',
                            value: typeOfFuel,
                          ),
                          _DetailField(
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
                            _DetailField(
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

class CarHeader extends StatelessWidget {
  final String make;
  final String model;
  final String licensePlate;

  const CarHeader({
    super.key,
    required this.make,
    required this.model,
    required this.licensePlate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '$make $model',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          if (licensePlate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                licensePlate,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMultiline;

  const _DetailField({
    required this.icon,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
