import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:carlog/add_car_screen.dart';
import 'package:carlog/car_details_model.dart';
import 'package:carlog/screens/car_overview/widgets/car_list_body.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:carlog/utils/data_migration.dart';

class CarOverviewScreen extends StatefulWidget {
  const CarOverviewScreen({super.key});

  @override
  _CarOverviewScreenState createState() => _CarOverviewScreenState();
}

class _CarOverviewScreenState extends State<CarOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer();
  final Duration _debounceDuration = Duration(milliseconds: 200);
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
              final text = _searchController.text.toLowerCase();
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              if (text.isEmpty) {
                await _fetchInitialCarDetails();
                return;
              }

              final collection = await FirebaseFirestore.instance
                  .collection('cars')
                  .where('userId', isEqualTo: userId)
                  .where('ownerName_insensitive',
                      isGreaterThanOrEqualTo: text,
                      isLessThan: text.substring(0, text.length - 1) +
                          String.fromCharCode(text.codeUnitAt(text.length - 1) + 1))
                  .get();

              setState(() {
                _cars = collection.docs.map((doc) => CarDetails.fromFirestore(doc, null)).toList();
              });
            } catch (e) {
              print(e);
            }
          });
    });
  }

  Future<void> _fetchInitialCarDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final collection = await FirebaseFirestore.instance.collection('cars').where('userId', isEqualTo: userId).get();

      setState(() {
        _cars = collection.docs.map((doc) => CarDetails.fromFirestore(doc, null)).toList();
      });
      _searchController.clear();
    } catch (e) {
      print(e);
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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final unmigratedCount = await DataMigration.checkUnmigratedCarsCount();

      if (!mounted) return;

      if (unmigratedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nema podataka za migraciju')),
        );
        return;
      }

      final shouldMigrate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Potvrda migracije'),
          content: Text('Pronađeno je $unmigratedCount automobila bez korisnika. '
              'Da li želite da ih dodelite trenutnom nalogu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Ne'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Da'),
            ),
          ],
        ),
      );

      if (!mounted || shouldMigrate != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Migracija podataka u toku...'),
            ],
          ),
        ),
      );

      await DataMigration.migrateExistingCarsToUser(userId);

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uspešno migrirano $unmigratedCount automobila'),
          duration: const Duration(seconds: 4),
        ),
      );

      await _fetchInitialCarDetails();
    } catch (e) {
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške prilikom migracije podataka'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Servis knjiga'),
          centerTitle: true,
          elevation: 0,
          actions: [
            if (kDebugMode) ...[
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _migrateData,
                tooltip: 'Migrate data',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Odjavi se',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pretraži po imenu',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(height: 16),
              Expanded(child: CarListBody(cars: _cars, onUpdate: _fetchInitialCarDetails)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddCarScreen(
                      onCarUpdate: _fetchInitialCarDetails,
                      type: Add(),
                    )),
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
