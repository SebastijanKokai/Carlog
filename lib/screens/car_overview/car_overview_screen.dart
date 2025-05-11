import 'dart:async';
import 'package:carlog/screens/car_entry/car_screen_type.dart';
import 'package:carlog/screens/car_entry/car_entry_screen.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/screens/car_overview/widgets/car_list_body.dart';
import 'package:carlog/screens/car_overview/widgets/car_overview_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:carlog/services/car_search_service.dart';
import 'package:carlog/services/data_migration_service.dart';
import 'package:carlog/widgets/search_field.dart';

class CarOverviewScreen extends StatefulWidget {
  const CarOverviewScreen({super.key});

  @override
  CarOverviewScreenState createState() => CarOverviewScreenState();
}

class CarOverviewScreenState extends State<CarOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer();
  final Duration _debounceDuration = Duration(milliseconds: 200);
  final CarSearchService _searchService = CarSearchService();
  final DataMigrationService _migrationService = DataMigrationService();
  List<CarDetails> _cars = [];

  @override
  void initState() {
    super.initState();
    unawaited(_fetchInitialCarDetails().then((_) => _initSearchListener()));
  }

  @override
  dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSearchListener() async {
    _searchController.addListener(() {
      _debouncer.debounce(
        duration: _debounceDuration,
        onDebounce: () async {
          try {
            final text = _searchController.text;
            final results = await _searchService.searchCars(text);

            if (!mounted) return;

            setState(() => _cars = results);
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Došlo je do greške prilikom pretrage'),
              ),
            );
          }
        },
      );
    });
  }

  Future<void> _fetchInitialCarDetails() async {
    try {
      final results = await _searchService.searchCars('');

      if (!mounted) return;

      setState(() => _cars = results);
      _searchController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Došlo je do greške prilikom učitavanja podataka'),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Došlo je do greške prilikom odjavljivanja')),
        );
      }
    }
  }

  Future<void> _migrateData() async {
    try {
      final unmigratedCount = await _migrationService.getUnmigratedCarsCount();

      if (!mounted) return;

      if (unmigratedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nema podataka za migraciju')),
        );
        return;
      }

      final shouldMigrate = await _migrationService.showMigrationConfirmationDialog(
        context,
        unmigratedCount,
      );

      if (!mounted || !shouldMigrate) return;

      _migrationService.showMigrationProgressDialog(context);

      await _migrationService.migrateCars();

      if (!mounted) return;

      Navigator.of(context).pop();
      _migrationService.showMigrationSuccessSnackBar(context, unmigratedCount);
      await _fetchInitialCarDetails();
    } catch (e) {
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _migrationService.showMigrationErrorSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CarOverviewAppBar(
          onLogout: _logout,
          onMigrateData: _migrateData,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchField(controller: _searchController),
              const SizedBox(height: 16),
              Expanded(child: CarListBody(cars: _cars, onUpdate: _fetchInitialCarDetails)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarEntryScreen(
                      onCarUpdate: _fetchInitialCarDetails,
                      type: Add(),
                    )),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
