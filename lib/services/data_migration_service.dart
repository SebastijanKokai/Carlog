import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carlog/constants/firebase_constants.dart';

class DataMigrationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DataMigrationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<int> getUnmigratedCarsCount() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.carsCollection)
          .where(FirebaseConstants.userId, isNull: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to check unmigrated cars count: $e');
    }
  }

  Future<void> migrateCars() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection(FirebaseConstants.carsCollection)
          .where(FirebaseConstants.userId, isNull: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {FirebaseConstants.userId: userId});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to migrate cars: $e');
    }
  }

  Future<bool> showMigrationConfirmationDialog(BuildContext context, int unmigratedCount) async {
    return await showDialog<bool>(
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
        ) ??
        false;
  }

  void showMigrationProgressDialog(BuildContext context) {
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
  }

  void showMigrationSuccessSnackBar(BuildContext context, int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uspešno migrirano $count automobila'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showMigrationErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Došlo je do greške prilikom migracije podataka'),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
