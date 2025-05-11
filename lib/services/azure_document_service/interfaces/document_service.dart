import 'dart:io';
import 'package:carlog/models/car_details_model.dart';

abstract class DocumentService {
  Future<Map<String, dynamic>> analyzeDriverLicense(File imageFile);
  CarDetails extractDriverLicenseFields(Map<String, dynamic> analysisResult);
}
