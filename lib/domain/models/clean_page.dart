class CleanPage {
  const CleanPage({
    required this.page,
    required this.text,
    required this.sourcePages,
    required this.modelUsed,
    required this.processedAt,
  });

  final int page;
  final String text;
  final List<int> sourcePages;
  final String modelUsed;
  final String processedAt;
}
