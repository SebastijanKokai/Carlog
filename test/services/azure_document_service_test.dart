import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:carlog/services/azure_document_service/azure_document_service.dart';
import 'package:carlog/services/azure_document_service/config/azure_config.dart';
import 'package:carlog/services/azure_document_service/exceptions/document_service_exceptions.dart';
import 'package:carlog/services/image_compression_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'azure_document_service_test.mocks.dart';

@GenerateMocks([http.Client, ImageCompressionService, File])
void main() {
  late MockClient mockHttpClient;
  late MockImageCompressionService mockImageCompressionService;
  late MockFile mockImageFile;
  late AzureDocumentService service;

  const config = AzureConfig(
    endpoint: 'https://test-endpoint.com',
    apiKey: 'test-api-key',
    customModelEndpoint: 'test-model',
  );

  setUp(() {
    mockHttpClient = MockClient();
    mockImageCompressionService = MockImageCompressionService();
    mockImageFile = MockFile();
    service = AzureDocumentService(
      config: config,
      httpClient: mockHttpClient,
      imageCompressionService: mockImageCompressionService,
    );
  });

  tearDown(() {
    mockHttpClient.close();
  });

  Map<String, dynamic> getMockAnalysisResult() => {
        'status': 'succeeded',
        'analyzeResult': {
          'documents': [
            {
              'fields': {
                'firstName': {'value': 'John'},
                'lastName': {'value': 'Doe'},
              }
            }
          ]
        }
      };

  http.Response getStartAnalysisResponse() => http.Response(
        '',
        202,
        headers: {'operation-location': 'https://test-endpoint.com/result'},
      );

  http.Response getResultResponse(Map<String, dynamic> result) => http.Response(
        jsonEncode(result),
        200,
      );

  void setupImageFile({int size = 1024}) {
    final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
    when(mockImageFile.readAsBytes()).thenAnswer((_) async => imageBytes);
    when(mockImageFile.length()).thenAnswer((_) async => size);
  }

  void setupHttpResponses({
    required http.Response startResponse,
    required http.Response resultResponse,
  }) {
    when(mockHttpClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => startResponse);

    when(mockHttpClient.get(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => resultResponse);
  }

  group('analyzeDriverLicense', () {
    test('should successfully analyze driver license', () async {
      setupImageFile();
      final analysisResult = getMockAnalysisResult();
      setupHttpResponses(
        startResponse: getStartAnalysisResponse(),
        resultResponse: getResultResponse(analysisResult),
      );

      final result = await service.analyzeDriverLicense(mockImageFile);
      expect(result, equals(analysisResult));
    });

    test('should compress image if size is greater than 4MB', () async {
      setupImageFile(size: 5 * 1024 * 1024);
      final imageBytes = [1, 2, 3, 4];
      when(mockImageCompressionService.compressImageFile(mockImageFile)).thenAnswer((_) async => imageBytes);

      final analysisResult = getMockAnalysisResult();
      setupHttpResponses(
        startResponse: getStartAnalysisResponse(),
        resultResponse: getResultResponse(analysisResult),
      );

      final result = await service.analyzeDriverLicense(mockImageFile);
      expect(result, equals(analysisResult));
      verify(mockImageCompressionService.compressImageFile(mockImageFile)).called(1);
      verifyNever(mockImageFile.readAsBytes());
    });

    test('should throw DocumentAnalysisException when start analysis fails', () async {
      setupImageFile();
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 400));

      expect(
        () => service.analyzeDriverLicense(mockImageFile),
        throwsA(isA<DocumentAnalysisException>()),
      );
    });

    test('should throw DocumentAnalysisException when operation location is missing', () async {
      setupImageFile();
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 202));

      expect(
        () => service.analyzeDriverLicense(mockImageFile),
        throwsA(isA<DocumentAnalysisException>()),
      );
    });

    test('should throw DocumentAnalysisException when analysis fails', () async {
      setupImageFile();
      final failedResult = {
        'status': 'failed',
        'error': {'message': 'Analysis failed'},
      };

      setupHttpResponses(
        startResponse: getStartAnalysisResponse(),
        resultResponse: getResultResponse(failedResult),
      );

      expect(
        () => service.analyzeDriverLicense(mockImageFile),
        throwsA(isA<DocumentAnalysisException>()),
      );
    });
  });
}
