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

  TextStyle? get carHeaderTitle => textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      );

  TextStyle get infoSectionTitle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      );

  BoxDecoration get infoSectionDecoration => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  TextStyle get detailFieldLabel => TextStyle(
        fontSize: 14,
        color: colorScheme.onSurface.withAlpha(179),
      );

  TextStyle get detailFieldValue => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  BoxDecoration get detailFieldIconDecoration => BoxDecoration(
        color: colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      );
}
