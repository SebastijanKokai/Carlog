import 'dart:convert';
import 'dart:typed_data';
import 'package:carlog/services/azure_document_service/config/azure_config.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../azure_document_service_test.mocks.dart';

class TestHelpers {
  final MockClient mockHttpClient;
  final AzureConfig config;

  TestHelpers({
    required this.mockHttpClient,
    required this.config,
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

  void setupImageFile(MockFile mockImageFile, {int size = 1024}) {
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
}
