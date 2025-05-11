import 'package:cloud_firestore/cloud_firestore.dart';

extension DocumentSnapshotX on DocumentSnapshot {
  String getString(String field) {
    return data().toString().contains(field) ? get(field) ?? '' : '';
  }
}
