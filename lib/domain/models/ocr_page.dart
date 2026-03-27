class OcrPage {
  const OcrPage({
    required this.page,
    required this.text,
    required this.processedAt,
  });

  final int page;
  final String text;
  final String processedAt;
}
