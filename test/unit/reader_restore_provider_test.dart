import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/data/json/processing_state_manager.dart';
import 'package:leaf_flutter/domain/models/book.dart';
import 'package:leaf_flutter/domain/models/processing_continuation_state.dart';
import 'package:leaf_flutter/domain/models/processing_status.dart';
import 'package:leaf_flutter/providers/book_providers.dart';
import 'package:leaf_flutter/providers/reader_provider.dart';
import 'package:leaf_flutter/services/file_service.dart';
import 'package:leaf_flutter/services/reader/reader_content_service.dart';

void main() {
  group('reader restore providers', () {
    test('continuationStateProvider reads the fresh book instead of stale cache', () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'leaf_reader_restore_state',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      const String bookId = 'book-1';
      final Book staleBook = _buildBook(
        id: bookId,
        lastReadPage: 1,
        aiProgress: 0,
      );
      final Book freshBook = _buildBook(
        id: bookId,
        lastReadPage: 42,
        aiProgress: 6,
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          bookProvider(bookId).overrideWith((Ref ref) async => staleBook),
          latestBookProvider(bookId).overrideWith((Ref ref) async => freshBook),
          fileServiceProvider.overrideWithValue(
            FileService(
              libraryPathProvider: () async => tempDir.path,
              documentsDirectoryProvider: () async => tempDir,
              temporaryDirectoryProvider: () async => tempDir,
            ),
          ),
          processingStateManagerProvider.overrideWithValue(
            _FakeProcessingStateManager(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final ProcessingContinuationState result = await container.read(
        continuationStateProvider(bookId).future,
      );

      expect(result.aiEnabledForBook, isTrue);
      expect(result.nextAiPage, 7);
    });

    test('readerViewProvider loads content from the fresh lastReadPage', () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'leaf_reader_restore_view',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      const String bookId = 'book-2';
      final Book staleBook = _buildBook(id: bookId, lastReadPage: 1);
      final Book freshBook = _buildBook(id: bookId, lastReadPage: 42);

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          bookProvider(bookId).overrideWith((Ref ref) async => staleBook),
          latestBookProvider(bookId).overrideWith((Ref ref) async => freshBook),
          fileServiceProvider.overrideWithValue(
            FileService(
              libraryPathProvider: () async => tempDir.path,
              documentsDirectoryProvider: () async => tempDir,
              temporaryDirectoryProvider: () async => tempDir,
            ),
          ),
          processingStateManagerProvider.overrideWithValue(
            _FakeProcessingStateManager(),
          ),
          readerContentServiceProvider.overrideWithValue(
            _FakeReaderContentService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final ReaderViewData result = await container.read(
        readerViewProvider(bookId).future,
      );

      expect(result.blocks, hasLength(1));
      expect(result.blocks.single.sourcePages, <int>[42]);
      expect(result.blocks.single.pageLabel, 'Page 42');
    });
  });
}

Book _buildBook({
  required String id,
  required int lastReadPage,
  int aiProgress = 0,
}) {
  return Book(
    id: id,
    name: 'Test Book',
    author: 'Tester',
    folderName: 'folder_$id',
    pdfFilename: 'book.pdf',
    coverPath: null,
    totalPages: 100,
    ocrProgress: 100,
    aiProgress: aiProgress,
    lastReadPage: lastReadPage,
    lastScrollOffset: 0.0,
    languageCode: 'en',
    status: BookProcessingState.ready,
    fileSize: 1234,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );
}

class _FakeProcessingStateManager extends ProcessingStateManager {
  @override
  Future<ProcessingContinuationState> read(String filePath) async {
    return ProcessingContinuationState.initial('');
  }
}

class _FakeReaderContentService extends ReaderContentService {
  @override
  Future<List<ReaderBlock>> loadContent({
    required Book book,
    required bool preferAi,
  }) async {
    return <ReaderBlock>[
      ReaderBlock(
        pageLabel: 'Page ${book.lastReadPage}',
        text: 'page ${book.lastReadPage}',
        aiCorrected: false,
        sourcePages: <int>[book.lastReadPage],
      ),
    ];
  }
}
