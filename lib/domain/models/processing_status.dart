enum BookProcessingState { pending, processing, ready, error }

enum ProcessingPhase { idle, downloadingLanguage, ocr, aiCleanup, done, error }

class ProcessingStatus {
  const ProcessingStatus({
    required this.phase,
    required this.currentPage,
    required this.totalPages,
    this.downloadProgress,
    this.errorMessage,
  });

  final ProcessingPhase phase;
  final int currentPage;
  final int totalPages;
  final String? downloadProgress;
  final String? errorMessage;

  factory ProcessingStatus.idle() => const ProcessingStatus(
    phase: ProcessingPhase.idle,
    currentPage: 0,
    totalPages: 0,
  );
}
