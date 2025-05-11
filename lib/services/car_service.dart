import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/constants/firebase_constants.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCar(CarDetails carDetails, {String? existingId}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final carWithUserId = carDetails.copyWith(userId: userId);

    if (existingId == null) {
      await _firestore.collection(FirebaseConstants.carsCollection).add(carWithUserId.toFirestore());
    } else {
      await _firestore.collection(FirebaseConstants.carsCollection).doc(existingId).update(carWithUserId.toFirestore());
    }
  }
}
