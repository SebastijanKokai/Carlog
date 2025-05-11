import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/services/azure_document_service/azure_document_service.dart';

class DriverLicenseService {
  final ImagePicker _picker = ImagePicker();
  final AzureDocumentService _azureService = AzureDocumentService.getInstance();

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    return image != null ? File(image.path) : null;
  }

  Future<CarDetails> scanDriverLicense(File image) async {
    final result = await _azureService.analyzeDriverLicense(image);
    return _azureService.extractDriverLicenseFields(result);
  }
}
