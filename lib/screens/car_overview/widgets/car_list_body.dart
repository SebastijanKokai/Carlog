import 'package:carlog/car_detail_screen.dart';
import 'package:carlog/car_details_model.dart';
import 'package:carlog/screens/car_overview/widgets/modify_buttons.dart';
import 'package:flutter/material.dart';

class CarListBody extends StatelessWidget {
  const CarListBody({super.key, required this.cars, required this.onUpdate});

  final List<CarDetails> cars;
  final Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Nema pronađenih automobila',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                car.ownerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${car.make ?? ''} ${car.model ?? ''}'.trim(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarDetailScreen(carId: car.id)),
              ),
              trailing: ModifyButtons(car: car, onUpdate: onUpdate),
            ),
          ),
        );
      },
    );
  }
}
