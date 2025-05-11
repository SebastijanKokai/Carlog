import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';

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
      decoration: context.infoSectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.infoSectionTitle,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
