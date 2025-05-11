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

  Uint8List getTestImageBytes() => Uint8List.fromList([1, 2, 3, 4]);

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
    final imageBytes = getTestImageBytes();
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

  void setupSuccessfulPostResponse({
    required String url,
    required List<int> imageBytes,
    required http.Response response,
  }) {
    when(mockHttpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
      body: jsonEncode({
        'base64Source': base64Encode(imageBytes),
      }),
    )).thenAnswer((_) async => response);
  }

  void setupFailedPostResponse({
    required String url,
    required List<int> imageBytes,
    required int statusCode,
  }) {
    when(mockHttpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
      body: jsonEncode({
        'base64Source': base64Encode(imageBytes),
      }),
    )).thenAnswer((_) async => http.Response('', statusCode));
  }

  void setupNetworkErrorPostResponse({
    required String url,
    required List<int> imageBytes,
  }) {
    when(mockHttpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
      body: jsonEncode({
        'base64Source': base64Encode(imageBytes),
      }),
    )).thenThrow(Exception('Network error'));
  }

  void verifyPostRequest({
    required String url,
    required List<int> imageBytes,
  }) {
    verify(mockHttpClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': config.apiKey,
      },
      body: jsonEncode({
        'base64Source': base64Encode(imageBytes),
      }),
    )).called(1);
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

  group('startAnalysis', () {
    test('should successfully start analysis', () async {
      final imageBytes = getTestImageBytes();
      final expectedResponse = getStartAnalysisResponse();
      setupSuccessfulPostResponse(
        url: 'https://test-endpoint.com/test-model',
        imageBytes: imageBytes,
        response: expectedResponse,
      );

      final response = await service.startAnalysis('https://test-endpoint.com/test-model', imageBytes);

      expect(response.statusCode, equals(202));
      expect(response.headers['operation-location'], equals('https://test-endpoint.com/result'));
      verifyPostRequest(
        url: 'https://test-endpoint.com/test-model',
        imageBytes: imageBytes,
      );
    });

    test('should throw DocumentAnalysisException when status code is not 202', () async {
      final imageBytes = getTestImageBytes();
      setupFailedPostResponse(
        url: 'https://test-endpoint.com/test-model',
        imageBytes: imageBytes,
        statusCode: 400,
      );

      expect(
        () => service.startAnalysis('https://test-endpoint.com/test-model', imageBytes),
        throwsA(isA<DocumentAnalysisException>().having(
          (e) => e.message,
          'message',
          'Failed to start analysis. Status code: 400',
        )),
      );
    });
  });
}
