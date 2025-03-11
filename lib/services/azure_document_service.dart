import 'dart:convert';
import 'dart:io';
import 'package:carlog/car_details_model.dart';
import 'package:carlog/services/image_compression_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AzureDocumentService {
  static AzureDocumentService? _instance;
  final String endpoint;
  final String apiKey;
  final String customModelEndpoint;

  AzureDocumentService._({
    required this.endpoint,
    required this.apiKey,
    required this.customModelEndpoint,
  });

  static AzureDocumentService getInstance() {
    _instance ??= AzureDocumentService._(
      endpoint: dotenv.env['AZURE_BASE_URL'] ?? '',
      apiKey: dotenv.env['AZURE_API_KEY'] ?? '',
      customModelEndpoint: dotenv.env['AZURE_CUSTOM_MODEL_ENDPOINT'] ?? '',
    );
    return _instance!;
  }

  Future<Map<String, dynamic>> analyzeDriverLicense(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      List<int> imageBytes;

      if (fileSizeInMB > 4) {
        imageBytes = await ImageCompressionService.getInstance().compressImageFile(imageFile);
      } else {
        imageBytes = await imageFile.readAsBytes();
      }

      final baseEndpoint = endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;

      final url = '$baseEndpoint/$customModelEndpoint';

      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': apiKey,
        },
        body: jsonEncode({
          'base64Source': base64Image,
        }),
      );

      if (response.statusCode != 202) {
        throw Exception('Failed to start analysis. Status code: ${response.statusCode}');
      }

      String operationLocation = response.headers['operation-location'] ?? '';
      if (operationLocation.isEmpty) {
        throw Exception('Operation location header not found');
      }

      // Poll for results
      for (int i = 0; i < 60; i++) {
        // timeout after 60 seconds
        final resultResponse = await http.get(
          Uri.parse(operationLocation),
          headers: {
            'Ocp-Apim-Subscription-Key': apiKey,
          },
        );

        if (resultResponse.statusCode != 200) {
          throw Exception('Error checking analysis status: ${resultResponse.statusCode}');
        }

        final result = jsonDecode(resultResponse.body);

        if (result['status'] == 'succeeded') {
          return result;
        } else if (result['status'] == 'failed') {
          throw Exception('Analysis failed: ${result['error']?['message']}');
        }

        await Future.delayed(Duration(seconds: 1));
      }
      throw Exception('Operation timed out');
    } catch (e) {
      throw Exception('Error analyzing document: $e');
    }
  }

  CarDetails extractDriverLicenseFields(Map<String, dynamic> analysisResult) {
    try {
      final documents = analysisResult['analyzeResult']['documents'] as List;

      if (documents.isEmpty) {
        throw Exception('No documents found in analysis result');
      }

      return CarDetails.fromAzureAnalysis(analysisResult);
    } catch (e) {
      throw Exception('Error extracting fields: $e');
    }
  }
}
