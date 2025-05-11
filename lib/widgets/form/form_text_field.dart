import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: context.primaryColor),
          border: context.formFieldBorder,
          enabledBorder: context.formFieldEnabledBorder,
          focusedBorder: context.formFieldFocusedBorder,
          filled: true,
          fillColor: context.surfaceColor,
        ),
      ),
    );
  }
}
