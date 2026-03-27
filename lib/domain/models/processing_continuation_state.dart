class ProcessingContinuationState {
  const ProcessingContinuationState({
    required this.bookId,
    required this.bootstrapComplete,
    required this.readerReady,
    required this.continuationMode,
    required this.nextOcrPage,
    required this.nextAiPage,
    required this.nextAiCharOffset,
    required this.firstGeminiBatchComplete,
    required this.nativeOcrActive,
  });

  final String bookId;
  final bool bootstrapComplete;
  final bool readerReady;
  final String continuationMode;
  final int nextOcrPage;
  final int nextAiPage;
  final int nextAiCharOffset;
  final bool firstGeminiBatchComplete;
  final bool nativeOcrActive;

  factory ProcessingContinuationState.initial(String bookId) =>
      ProcessingContinuationState(
        bookId: bookId,
        bootstrapComplete: false,
        readerReady: false,
        continuationMode: 'none',
        nextOcrPage: 1,
        nextAiPage: 1,
        nextAiCharOffset: 0,
        firstGeminiBatchComplete: false,
        nativeOcrActive: false,
      );

  ProcessingContinuationState copyWith({
    bool? bootstrapComplete,
    bool? readerReady,
    String? continuationMode,
    int? nextOcrPage,
    int? nextAiPage,
    int? nextAiCharOffset,
    bool? firstGeminiBatchComplete,
    bool? nativeOcrActive,
  }) {
    return ProcessingContinuationState(
      bookId: bookId,
      bootstrapComplete: bootstrapComplete ?? this.bootstrapComplete,
      readerReady: readerReady ?? this.readerReady,
      continuationMode: continuationMode ?? this.continuationMode,
      nextOcrPage: nextOcrPage ?? this.nextOcrPage,
      nextAiPage: nextAiPage ?? this.nextAiPage,
      nextAiCharOffset: nextAiCharOffset ?? this.nextAiCharOffset,
      firstGeminiBatchComplete:
          firstGeminiBatchComplete ?? this.firstGeminiBatchComplete,
      nativeOcrActive: nativeOcrActive ?? this.nativeOcrActive,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bookId': bookId,
      'bootstrapComplete': bootstrapComplete,
      'readerReady': readerReady,
      'continuationMode': continuationMode,
      'nextOcrPage': nextOcrPage,
      'nextAiPage': nextAiPage,
      'nextAiCharOffset': nextAiCharOffset,
      'firstGeminiBatchComplete': firstGeminiBatchComplete,
      'nativeOcrActive': nativeOcrActive,
    };
  }

  factory ProcessingContinuationState.fromJson(Map<String, Object?> json) {
    return ProcessingContinuationState(
      bookId: json['bookId'] as String? ?? '',
      bootstrapComplete: json['bootstrapComplete'] as bool? ?? false,
      readerReady: json['readerReady'] as bool? ?? false,
      continuationMode: json['continuationMode'] as String? ?? 'none',
      nextOcrPage: json['nextOcrPage'] as int? ?? 1,
      nextAiPage: json['nextAiPage'] as int? ?? 1,
      nextAiCharOffset: json['nextAiCharOffset'] as int? ?? 0,
      firstGeminiBatchComplete:
          json['firstGeminiBatchComplete'] as bool? ?? false,
      nativeOcrActive: json['nativeOcrActive'] as bool? ?? false,
    );
  }
}
