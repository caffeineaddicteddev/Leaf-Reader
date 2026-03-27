sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class PipelineException extends AppException {
  const PipelineException(super.message, {this.pageNum});

  final int? pageNum;
}

final class OcrException extends AppException {
  const OcrException(super.message, {required this.pageNum});

  final int pageNum;
}

final class AiException extends AppException {
  const AiException(super.message, {required this.model, this.statusCode});

  final String model;
  final int? statusCode;
}

final class LanguageDownloadException extends AppException {
  const LanguageDownloadException(this.language, super.message);

  final String language;
}

final class FileException extends AppException {
  const FileException(super.message, {this.path});

  final String? path;
}

final class SettingsException extends AppException {
  const SettingsException(super.message);
}
