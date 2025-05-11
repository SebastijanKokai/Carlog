import 'package:flutter_dotenv/flutter_dotenv.dart';

class AzureConfig {
  final String endpoint;
  final String apiKey;
  final String customModelEndpoint;
  final Duration pollingTimeout;
  final Duration pollingInterval;

  const AzureConfig({
    required this.endpoint,
    required this.apiKey,
    required this.customModelEndpoint,
    this.pollingTimeout = const Duration(seconds: 60),
    this.pollingInterval = const Duration(seconds: 1),
  });

  factory AzureConfig.fromEnv() {
    return AzureConfig(
      endpoint: dotenv.env['AZURE_BASE_URL'] ?? '',
      apiKey: dotenv.env['AZURE_API_KEY'] ?? '',
      customModelEndpoint: dotenv.env['AZURE_CUSTOM_MODEL_ENDPOINT'] ?? '',
    );
  }
}
