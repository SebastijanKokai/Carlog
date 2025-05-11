import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:carlog/services/azure_document_service/azure_document_service.dart';
import 'package:carlog/services/azure_document_service/config/azure_config.dart';
import 'package:carlog/services/image_compression_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<ImageCompressionService>(() => ImageCompressionService.getInstance());
  getIt.registerLazySingleton<AzureConfig>(() => AzureConfig.fromEnv());
  getIt.registerLazySingleton<AzureDocumentService>(
    () => AzureDocumentService(
      config: getIt<AzureConfig>(),
      httpClient: getIt<http.Client>(),
      imageCompressionService: getIt<ImageCompressionService>(),
    ),
  );
}
