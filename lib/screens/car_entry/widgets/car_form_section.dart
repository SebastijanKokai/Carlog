import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

class CarFormSection extends StatelessWidget {
  final String title;
  final List<Widget> fields;

  const CarFormSection({
    super.key,
    required this.title,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: context.sectionTitle,
        ),
        const SizedBox(height: 16),
        ...fields,
      ],
    );
  }
}
