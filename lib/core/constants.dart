class AppConstants {
  const AppConstants._();

  static const String appName = 'Leaf';
  static const String nativeChannel = 'com.spark.leaf/native';
  static const String libraryFolderName = 'LeafLibrary';
  static const String ocrJsonFileName = 'book_ocr.json';
  static const String cleanJsonFileName = 'book_clean.json';
  static const String processingStateFileName = 'processing_state.json';
  static const String aiEndpointBase =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const int defaultRenderDpi = 300;
}
