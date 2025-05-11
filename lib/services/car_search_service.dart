import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/constants/firebase_constants.dart';

class CarSearchService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CarSearchService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<CarDetails>> searchCars(String query) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      if (query.isEmpty) {
        return await _fetchAllCars(userId);
      }

      final collection = await _firestore
          .collection(FirebaseConstants.carsCollection)
          .where(FirebaseConstants.userId, isEqualTo: userId)
          .where(FirebaseConstants.ownerNameInsensitive,
              isGreaterThanOrEqualTo: query.toLowerCase(), isLessThan: _getNextString(query.toLowerCase()))
          .get();

      return collection.docs.map((doc) => CarDetails.fromFirestore(doc, null)).toList();
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  Future<List<CarDetails>> _fetchAllCars(String userId) async {
    try {
      final collection = await _firestore
          .collection(FirebaseConstants.carsCollection)
          .where(FirebaseConstants.userId, isEqualTo: userId)
          .get();

      return collection.docs.map((doc) => CarDetails.fromFirestore(doc, null)).toList();
    } catch (e) {
      // TODO: Add proper error logging
      rethrow;
    }
  }

  String _getNextString(String text) {
    if (text.isEmpty) return '';
    return text.substring(0, text.length - 1) + String.fromCharCode(text.codeUnitAt(text.length - 1) + 1);
  }
}
