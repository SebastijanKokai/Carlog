import 'package:cloud_firestore/cloud_firestore.dart';

class DataMigration {
  static Future<int> checkUnmigratedCarsCount() async {
    try {
      final QuerySnapshot carsWithoutUser =
          await FirebaseFirestore.instance.collection('cars').where('userId', isNull: true).get();

      return carsWithoutUser.docs.length;
    } catch (e) {
      print('Error checking unmigrated cars count: $e');
      rethrow;
    }
  }

  static Future<void> migrateExistingCarsToUser(String userId) async {
    try {
      final QuerySnapshot carsWithoutUser =
          await FirebaseFirestore.instance.collection('cars').where('userId', isNull: true).get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in carsWithoutUser.docs) {
        batch.update(doc.reference, {'userId': userId});
      }

      await batch.commit();

      print('Successfully migrated ${carsWithoutUser.docs.length} cars to user $userId');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    }
  }
}
