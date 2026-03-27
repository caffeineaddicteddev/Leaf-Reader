import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/clean_page.dart';
import '../domain/models/book.dart';
import '../services/reader/reader_ai_service.dart';
import '../services/reader/reader_content_service.dart';
import 'book_providers.dart';
import 'settings_provider.dart';

final cleanPagesProvider = StreamProvider.family<List<CleanPage>, String>(
  (Ref ref, String bookId) => const Stream<List<CleanPage>>.empty(),
);

final StateProvider<Map<String, double>> readerProgressProvider =
    StateProvider<Map<String, double>>((Ref ref) => <String, double>{});

final Provider<ReaderContentService> readerContentServiceProvider =
    Provider<ReaderContentService>((Ref ref) => ReaderContentService());

final Provider<ReaderAiService> readerAiServiceProvider =
    Provider<ReaderAiService>((Ref ref) => ReaderAiService());

final readerAiToggleProvider = StateProvider.family<bool, String>((
  Ref ref,
  String bookId,
) {
  return true;
});

final readerBlocksProvider = FutureProvider.family<List<ReaderBlock>, String>((
  Ref ref,
  String bookId,
) async {
  final Book? book = await ref.watch(bookProvider(bookId).future);
  if (book == null) {
    return <ReaderBlock>[];
  }
  final bool preferAi = ref.watch(readerAiToggleProvider(bookId));
  return ref
      .watch(readerContentServiceProvider)
      .loadContent(book: book, preferAi: preferAi);
});

class ReaderAiController extends StateNotifier<AsyncValue<void>> {
  ReaderAiController(this.ref) : super(const AsyncData<void>(null));

  final Ref ref;

  Future<void> enableAi(String bookId) async {
    state = const AsyncLoading<void>();
    try {
      final Book? book = await ref.read(bookProvider(bookId).future);
      final AppSettings settings = await ref.read(settingsProvider.future);
      if (book == null) {
        state = const AsyncData<void>(null);
        return;
      }
      await ref
          .read(readerAiServiceProvider)
          .runCleanup(
            book: book,
            apiKey: settings.aiApiKey,
            geminiModel: settings.geminiModel,
            gemmaModel: settings.gemmaModel,
          );
      ref.read(readerAiToggleProvider(bookId).notifier).state = true;
      ref.invalidate(readerBlocksProvider(bookId));
      state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
    }
  }
}

final readerAiControllerProvider =
    StateNotifierProvider.family<ReaderAiController, AsyncValue<void>, String>(
      (Ref ref, String bookId) => ReaderAiController(ref),
    );
