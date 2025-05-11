class DocumentServiceException implements Exception {
  final String message;
  final dynamic originalError;

  DocumentServiceException(this.message, [this.originalError]);

  @override
  String toString() => 'DocumentServiceException: $message${originalError != null ? ' ($originalError)' : ''}';
}

class DocumentAnalysisException extends DocumentServiceException {
  DocumentAnalysisException(super.message, [super.originalError]);
}

class DocumentExtractionException extends DocumentServiceException {
  DocumentExtractionException(super.message, [super.originalError]);
}
