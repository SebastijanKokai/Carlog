import 'package:carlog/add_car_screen.dart';
import 'package:carlog/car_details_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModifyButtons extends StatelessWidget {
  const ModifyButtons({super.key, required this.car, required this.onUpdate});

  final CarDetails car;
  final Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EditIcon(car: car, onUpdate: onUpdate),
        _DeleteIcon(carId: car.id, onUpdate: onUpdate),
      ],
    );
  }
}

class _EditIcon extends StatelessWidget {
  const _EditIcon({required this.car, required this.onUpdate});

  final CarDetails car;
  final Function() onUpdate;

  void _onPressed(BuildContext context, Function() onCarUpdate, CarDetails car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCarScreen(
          onCarUpdate: onCarUpdate,
          type: Edit(car),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _onPressed(context, onUpdate, car),
      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _DeleteIcon extends StatelessWidget {
  const _DeleteIcon({required this.carId, required this.onUpdate});

  final String carId;
  final Function() onUpdate;

  void _deleteCar(BuildContext context) async {
    try {
      await _dialogBuilder(context, () => _deleteCarFromFirestore());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteCarFromFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
      onUpdate();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _dialogBuilder(BuildContext context, Function() onConfirm) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Da li ste sigurni da želite da izbrišete ovaj auto?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Ne',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Da',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _deleteCar(context),
      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
    );
  }
}
