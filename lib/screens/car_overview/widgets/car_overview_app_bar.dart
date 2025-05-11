import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CarOverviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  final VoidCallback onMigrateData;

  const CarOverviewAppBar({
    super.key,
    required this.onLogout,
    required this.onMigrateData,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Servis knjiga'),
      centerTitle: true,
      elevation: 0,
      actions: [
        if (kDebugMode) ...[
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: onMigrateData,
            tooltip: 'Migrate data',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Odjavi se',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
