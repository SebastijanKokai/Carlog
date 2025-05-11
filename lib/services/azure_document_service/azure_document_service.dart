import 'dart:convert';
import 'dart:io';
import 'package:carlog/models/car_details_model.dart';
import 'package:carlog/services/azure_document_service/config/azure_config.dart';
import 'package:carlog/services/azure_document_service/exceptions/document_service_exceptions.dart';
import 'package:carlog/services/image_compression_service.dart';
import 'package:carlog/services/azure_document_service/interfaces/document_service.dart';
import 'package:http/http.dart' as http;

class AzureDocumentService implements DocumentService {
  static AzureDocumentService? _instance;
  final AzureConfig config;
  final http.Client _httpClient;
  final ImageCompressionService _imageCompressionService;

  AzureDocumentService._({
    required this.config,
    required http.Client httpClient,
    required ImageCompressionService imageCompressionService,
  })  : _httpClient = httpClient,
        _imageCompressionService = imageCompressionService;

  static AzureDocumentService getInstance({
    http.Client? httpClient,
    ImageCompressionService? imageCompressionService,
  }) {
    _instance ??= AzureDocumentService._(
      config: AzureConfig.fromEnv(),
      httpClient: httpClient ?? http.Client(),
      imageCompressionService: imageCompressionService ?? ImageCompressionService.getInstance(),
    );
    return _instance!;
  }

  @override
  Future<Map<String, dynamic>> analyzeDriverLicense(File imageFile) async {
    try {
      final imageBytes = await _prepareImage(imageFile);
      final url = _buildAnalysisUrl();

      final response = await _startAnalysis(url, imageBytes);
      final operationLocation = _extractOperationLocation(response);

      return await _pollForResults(operationLocation);
    } catch (e) {
      throw DocumentAnalysisException('Failed to analyze document', e);
    }
  }

  Future<List<int>> _prepareImage(File imageFile) async {
    final fileSize = await imageFile.length();
    final fileSizeInMB = fileSize / (1024 * 1024);

    if (fileSizeInMB > 4) {
      return await _imageCompressionService.compressImageFile(imageFile);
    }
    return await imageFile.readAsBytes();
  }

  String _buildAnalysisUrl() {
    final baseEndpoint =
        config.endpoint.endsWith('/') ? config.endpoint.substring(0, config.endpoint.length - 1) : config.endpoint;
    return '$baseEndpoint/${config.customModelEndpoint}';
  }

  Future<http.Response> _startAnalysis(String url, List<int> imageBytes) async {
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
      body: jsonEncode({
        'base64Source': base64Encode(imageBytes),
      }),
    );

    if (response.statusCode != 202) {
      throw DocumentAnalysisException('Failed to start analysis. Status code: ${response.statusCode}');
    }

    return response;
  }

  String _extractOperationLocation(http.Response response) {
    final operationLocation = response.headers['operation-location'];
    if (operationLocation == null || operationLocation.isEmpty) {
      throw DocumentAnalysisException('Operation location header not found');
    }
    return operationLocation;
  }

  Future<Map<String, dynamic>> _pollForResults(String operationLocation) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < config.pollingTimeout) {
      final result = await _checkAnalysisStatus(operationLocation);

      if (result['status'] == 'succeeded') {
        return result;
      } else if (result['status'] == 'failed') {
        throw DocumentAnalysisException('Analysis failed: ${result['error']?['message']}');
      }

      await Future.delayed(config.pollingInterval);
    }

    throw DocumentAnalysisException('Operation timed out');
  }

  Future<Map<String, dynamic>> _checkAnalysisStatus(String operationLocation) async {
    final response = await _httpClient.get(
      Uri.parse(operationLocation),
      headers: {
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw DocumentAnalysisException('Error checking analysis status: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  @override
  CarDetails extractDriverLicenseFields(Map<String, dynamic> analysisResult) {
    try {
      final documents = analysisResult['analyzeResult']['documents'] as List;

      if (documents.isEmpty) {
        throw DocumentExtractionException('No documents found in analysis result');
      }

      return CarDetails.fromAzureAnalysis(analysisResult);
    } catch (e) {
      throw DocumentExtractionException('Error extracting fields', e);
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
