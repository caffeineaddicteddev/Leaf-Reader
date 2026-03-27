enum OcrEngine { mlkit, tesseract }

class OcrLanguage {
  const OcrLanguage({
    required this.displayName,
    required this.code,
    required this.engine,
    required this.mlkitScript,
    required this.mlkitNeedsDownload,
    required this.tessCode,
    required this.bundled,
  });

  final String displayName;
  final String code;
  final OcrEngine engine;
  final String? mlkitScript;
  final bool mlkitNeedsDownload;
  final String? tessCode;
  final bool bundled;
}
