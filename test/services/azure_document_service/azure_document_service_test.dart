import 'dart:io';
import 'package:carlog/services/azure_document_service/azure_document_service.dart';
import 'package:carlog/services/azure_document_service/config/azure_config.dart';
import 'package:carlog/services/azure_document_service/exceptions/document_service_exceptions.dart';
import 'package:carlog/services/image_compression_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'azure_document_service_test.mocks.dart';
import 'helpers/test_helpers.dart';

@GenerateMocks([http.Client, ImageCompressionService, File])
void main() {
  late MockClient mockHttpClient;
  late MockImageCompressionService mockImageCompressionService;
  late MockFile mockImageFile;
  late TestHelpers testHelpers;
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
    testHelpers = TestHelpers(
      mockHttpClient: mockHttpClient,
      config: config,
    );
    service = AzureDocumentService(
      config: config,
      httpClient: mockHttpClient,
      imageCompressionService: mockImageCompressionService,
    );
  });

  tearDown(() {
    mockHttpClient.close();
  });

  group('analyzeDriverLicense', () {
    test('should successfully analyze driver license', () async {
      testHelpers.setupImageFile(mockImageFile);
      final analysisResult = testHelpers.getMockAnalysisResult();
      testHelpers.setupHttpResponses(
        startResponse: testHelpers.getStartAnalysisResponse(),
        resultResponse: testHelpers.getResultResponse(analysisResult),
      );

      final result = await service.analyzeDriverLicense(mockImageFile);
      expect(result, equals(analysisResult));
    });

    test('should compress image if size is greater than 4MB', () async {
      testHelpers.setupImageFile(mockImageFile, size: 5 * 1024 * 1024);
      final imageBytes = [1, 2, 3, 4];
      when(mockImageCompressionService.compressImageFile(mockImageFile)).thenAnswer((_) async => imageBytes);

      final analysisResult = testHelpers.getMockAnalysisResult();
      testHelpers.setupHttpResponses(
        startResponse: testHelpers.getStartAnalysisResponse(),
        resultResponse: testHelpers.getResultResponse(analysisResult),
      );

      final result = await service.analyzeDriverLicense(mockImageFile);
      expect(result, equals(analysisResult));
      verify(mockImageCompressionService.compressImageFile(mockImageFile)).called(1);
      verifyNever(mockImageFile.readAsBytes());
    });

    test('should throw DocumentAnalysisException when start analysis fails', () async {
      testHelpers.setupImageFile(mockImageFile);
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
      testHelpers.setupImageFile(mockImageFile);
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
      testHelpers.setupImageFile(mockImageFile);
      final failedResult = {
        'status': 'failed',
        'error': {'message': 'Analysis failed'},
      };

      testHelpers.setupHttpResponses(
        startResponse: testHelpers.getStartAnalysisResponse(),
        resultResponse: testHelpers.getResultResponse(failedResult),
      );

      expect(
        () => service.analyzeDriverLicense(mockImageFile),
        throwsA(isA<DocumentAnalysisException>()),
      );
    });
  });

  group('startAnalysis', () {
    test('should successfully start analysis', () async {
      final imageBytes = testHelpers.getTestImageBytes();
      final expectedResponse = testHelpers.getStartAnalysisResponse();
      testHelpers.setupSuccessfulPostResponse(
        url: 'https://test-endpoint.com/test-model',
        imageBytes: imageBytes,
        response: expectedResponse,
      );

      final response = await service.startAnalysis('https://test-endpoint.com/test-model', imageBytes);

      expect(response.statusCode, equals(202));
      expect(response.headers['operation-location'], equals('https://test-endpoint.com/result'));
      testHelpers.verifyPostRequest(
        url: 'https://test-endpoint.com/test-model',
        imageBytes: imageBytes,
      );
    });

    test('should throw DocumentAnalysisException when status code is not 202', () async {
      final imageBytes = testHelpers.getTestImageBytes();
      testHelpers.setupFailedPostResponse(
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

  group('extractDriverLicenseFields', () {
    test('should successfully extract fields from analysis result', () {
      final analysisResult = {
        'analyzeResult': {
          'documents': [
            {
              'fields': {
                'first_name': {'valueString': 'John'},
                'last_name': {'valueString': 'Doe'},
                'car_make': {'valueString': 'Toyota'},
                'car_model': {'valueString': 'Corolla'},
                'chassis_number': {'valueString': 'CH123456'},
                'engine_displacement': {'valueString': '1.8L'},
                'engine_power': {'valueString': '132hp'},
                'type_of_fuel': {'valueString': 'Petrol'},
                'license_plate': {'valueString': 'ABC123'},
                'city': {'valueString': 'New York'},
                'address': {'valueString': '123 Main St'},
              }
            }
          ]
        }
      };

      final result = service.extractDriverLicenseFields(analysisResult);

      expect(result.ownerName, equals('Doe John'));
      expect(result.make, equals('Toyota'));
      expect(result.model, equals('Corolla'));
      expect(result.chassisNumber, equals('CH123456'));
      expect(result.engineDisplacement, equals('1.8L'));
      expect(result.enginePower, equals('132hp'));
      expect(result.typeOfFuel, equals('Petrol'));
      expect(result.licensePlate, equals('ABC123'));
      expect(result.city, equals('New York'));
      expect(result.address, equals('123 Main St'));
    });

    test('should throw DocumentExtractionException when no documents found', () {
      final analysisResult = {
        'analyzeResult': {'documents': []}
      };

      expect(
        () => service.extractDriverLicenseFields(analysisResult),
        throwsA(isA<DocumentExtractionException>().having(
          (e) => e.message,
          'message',
          contains('Error extracting fields'),
        )),
      );
    });

    test('should handle missing optional fields', () {
      final minimalResult = {
        'analyzeResult': {
          'documents': [
            {
              'fields': {
                'first_name': {'valueString': 'John'},
                'last_name': {'valueString': 'Doe'},
              }
            }
          ]
        }
      };

      final result = service.extractDriverLicenseFields(minimalResult);

      expect(result.ownerName, equals('Doe John'));
      expect(result.make, equals(''));
      expect(result.model, equals(''));
      expect(result.chassisNumber, equals(''));
      expect(result.engineDisplacement, equals(''));
      expect(result.enginePower, equals(''));
      expect(result.typeOfFuel, equals(''));
      expect(result.licensePlate, equals(''));
      expect(result.city, equals(''));
      expect(result.address, equals(''));
    });
  });
}
