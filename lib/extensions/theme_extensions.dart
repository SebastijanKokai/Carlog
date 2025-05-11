import 'package:flutter/material.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  TextStyle? get headlineStyle => textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      );
  TextStyle get sectionTitle =>
      textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ) ??
      const TextStyle(fontWeight: FontWeight.bold);

  Color get primaryColor => colorScheme.primary;
  Color get surfaceColor => colorScheme.surface;
  Color get outlineColor => colorScheme.outline.withAlpha(51);

  InputBorder get inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineColor),
      );
}
