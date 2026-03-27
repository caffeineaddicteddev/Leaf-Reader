import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/book.dart';
import '../services/reader/reader_ai_service.dart';
import '../services/reader/reader_content_service.dart';
import 'book_providers.dart';
import 'settings_provider.dart';

final Provider<ReaderContentService> readerContentServiceProvider =
    Provider<ReaderContentService>((Ref ref) => ReaderContentService());

final Provider<ReaderAiService> readerAiServiceProvider =
    Provider<ReaderAiService>((Ref ref) => ReaderAiService());

final readerBlocksProvider = FutureProvider.family<List<ReaderBlock>, String>((
  Ref ref,
  String bookId,
) async {
  final Book? book = await ref.watch(bookProvider(bookId).future);
  if (book == null) {
    return <ReaderBlock>[];
  }
  final AppSettings settings = await ref.watch(settingsProvider.future);
  return ref
      .watch(readerContentServiceProvider)
      .loadContent(book: book, preferAi: settings.aiMode);
});
