import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

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
        color: context.colorScheme.primaryContainer.withAlpha(51),
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
            color: context.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '$make $model',
            style: context.carHeaderTitle,
          ),
          if (licensePlate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
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
