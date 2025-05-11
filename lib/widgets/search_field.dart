import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Pretraži po imenu',
    this.prefixIcon = Icons.search,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: context.primaryColor),
        border: context.inputBorder,
        enabledBorder: context.inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor),
        ),
        filled: true,
        fillColor: context.surfaceColor,
      ),
    );
  }
}
