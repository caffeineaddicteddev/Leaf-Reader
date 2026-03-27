import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/json/processing_state_manager.dart';
import '../domain/models/book.dart';
import '../domain/models/processing_continuation_state.dart';
import '../domain/models/processing_status.dart';
import '../services/reader/reader_ai_service.dart';
import '../services/reader/reader_content_service.dart';
import 'book_providers.dart';

class ReaderViewData {
  const ReaderViewData({
    required this.blocks,
    required this.showLoading,
    required this.aiModeEnabled,
  });

  final List<ReaderBlock> blocks;
  final bool showLoading;
  final bool aiModeEnabled;
}

final Provider<ReaderContentService> readerContentServiceProvider =
    Provider<ReaderContentService>((Ref ref) => ReaderContentService());

final Provider<ReaderAiService> readerAiServiceProvider =
    Provider<ReaderAiService>((Ref ref) => ReaderAiService());

final Provider<ProcessingStateManager> processingStateManagerProvider =
    Provider<ProcessingStateManager>((Ref ref) => ProcessingStateManager());

final continuationStateProvider =
    FutureProvider.family<ProcessingContinuationState, String>((
      Ref ref,
      String bookId,
    ) async {
      final Book? book = await ref.watch(bookProvider(bookId).future);
      if (book == null) {
        return ProcessingContinuationState.initial(bookId);
      }
      final String statePath = await ref
          .watch(fileServiceProvider)
          .getProcessingStatePath(book.folderName);
      final ProcessingContinuationState current = await ref
          .watch(processingStateManagerProvider)
          .read(statePath);
      if (current.bookId.isEmpty) {
        return ProcessingContinuationState.initial(book.id).copyWith(
          bootstrapComplete: true,
          readerReady: true,
          continuationMode: book.status == BookProcessingState.processing
              ? 'ocr_only'
              : 'none',
          aiEnabledForBook: book.aiProgress > 0,
          aiCanceledByUser: book.aiProgress == 0,
          ocrPending: book.status == BookProcessingState.processing,
          aiPending: book.aiProgress > 0 && book.aiProgress < book.totalPages,
          nextOcrPage: book.ocrProgress + 1,
          nextAiPage: book.aiProgress > 0 ? book.aiProgress + 1 : 1,
        );
      }
      return current;
    });

final readerViewProvider = FutureProvider.family<ReaderViewData, String>((
  Ref ref,
  String bookId,
) async {
  final Book? book = await ref.watch(bookProvider(bookId).future);
  if (book == null) {
    return const ReaderViewData(
      blocks: <ReaderBlock>[],
      showLoading: false,
      aiModeEnabled: false,
    );
  }
  final ProcessingContinuationState continuation = await ref.watch(
    continuationStateProvider(bookId).future,
  );
  final bool preferAi = continuation.aiEnabledForBook;
  final List<ReaderBlock> blocks = await ref
      .watch(readerContentServiceProvider)
      .loadContent(book: book, preferAi: preferAi);
  return ReaderViewData(
    blocks: blocks,
    showLoading:
        continuation.ocrPending ||
        (continuation.aiEnabledForBook && continuation.aiPending),
    aiModeEnabled: continuation.aiEnabledForBook,
  );
});
