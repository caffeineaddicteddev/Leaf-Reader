import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/errors.dart';
import '../data/json/clean_json_manager.dart';
import '../data/json/ocr_json_manager.dart';
import '../data/repositories/book_repository.dart';
import '../domain/language_registry.dart';
import '../domain/models/book.dart';
import '../domain/models/ocr_language.dart';
import '../domain/models/ocr_page.dart';
import '../domain/models/processing_status.dart';
import '../services/file_service.dart';
import '../services/platform/leaf_platform_channel.dart';
import '../services/reader/reader_ai_service.dart';
import 'book_providers.dart';
import 'settings_provider.dart';

enum PipelineCancelResult { none, deleted, keptOcr }

enum _CancelMode { none, deleteBook, keepOcr }

class PipelineNotifier extends StateNotifier<ProcessingStatus> {
  PipelineNotifier(this._ref, this._bookId)
    : _bookRepository = _ref.read(bookRepositoryProvider),
      _fileService = _ref.read(fileServiceProvider),
      _platformChannel = LeafPlatformChannel(),
      _ocrJsonManager = OcrJsonManager(),
      _cleanJsonManager = CleanJsonManager(),
      _readerAiService = ReaderAiService(),
      super(ProcessingStatus.idle());

  final Ref _ref;
  final String _bookId;
  final BookRepository _bookRepository;
  final FileService _fileService;
  final LeafPlatformChannel _platformChannel;
  final OcrJsonManager _ocrJsonManager;
  final CleanJsonManager _cleanJsonManager;
  final ReaderAiService _readerAiService;

  bool _cancelRequested = false;
  _CancelMode _cancelMode = _CancelMode.none;
  Future<void>? _activeTask;

  Future<void> startPipeline() async {
    if (_activeTask != null) {
      return _activeTask;
    }
    _cancelRequested = false;
    _cancelMode = _CancelMode.none;
    state = const ProcessingStatus(
      phase: ProcessingPhase.ocr,
      currentPage: 0,
      totalPages: 0,
      ocrCompletedPages: 0,
      aiCompletedPages: 0,
      readerReady: false,
    );
    _activeTask = _runPipeline();
    return _activeTask;
  }

  Future<PipelineCancelResult> cancelPipeline() async {
    if (_activeTask == null) {
      state = ProcessingStatus.idle();
      return PipelineCancelResult.none;
    }
    _cancelRequested = true;
    _cancelMode = state.readerReady || state.aiCompletedPages > 0
        ? _CancelMode.keepOcr
        : _CancelMode.deleteBook;
    await _activeTask;
    return switch (_cancelMode) {
      _CancelMode.keepOcr => PipelineCancelResult.keptOcr,
      _CancelMode.deleteBook => PipelineCancelResult.deleted,
      _CancelMode.none => PipelineCancelResult.none,
    };
  }

  Future<void> deleteBook() async {
    _cancelRequested = true;
    _cancelMode = _CancelMode.deleteBook;
    if (_activeTask != null) {
      await _activeTask;
      return;
    }
    final Book? book = await _bookRepository.getBook(_bookId);
    if (book == null) {
      state = ProcessingStatus.idle();
      return;
    }
    await _deleteBookAssets(book);
    state = ProcessingStatus.idle();
  }

  Future<void> _runPipeline() async {
    try {
      final Book? book = await _bookRepository.getBook(_bookId);
      if (book == null) {
        throw const PipelineException('Book not found.');
      }

      final OcrLanguage language = LanguageRegistry.byCode(book.languageCode);
      final String pdfPath = await _fileService.getPdfPath(book);
      final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
      final String cleanPath = await _fileService.getCleanJsonPath(
        book.folderName,
      );
      final int totalPages = book.totalPages > 0
          ? book.totalPages
          : await _fileService.getPageCount(pdfPath);
      final int firstAiBatchEnd = totalPages < 10 ? totalPages : 10;

      await _ocrJsonManager.clear(ocrPath);
      await _ocrJsonManager.initialize(filePath: ocrPath, bookId: book.id);
      await _cleanJsonManager.clear(cleanPath);
      await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
      await _bookRepository.updateProgress(
        id: book.id,
        ocrProgress: 0,
        aiProgress: 0,
        status: BookProcessingState.processing.name,
      );

      await _prepareLanguage(language, totalPages);
      if (await _handleCancellation(book, cleanPath)) {
        return;
      }

      await _runOcr(
        bookId: book.id,
        pdfPath: pdfPath,
        ocrPath: ocrPath,
        language: language,
        totalPages: totalPages,
        startPage: 1,
        endPage: firstAiBatchEnd,
      );
      if (await _handleCancellation(book, cleanPath)) {
        return;
      }

      final settings = await _ref.read(settingsProvider.future);
      if (settings.aiMode && settings.aiApiKey.trim().isNotEmpty) {
        await _runCleanupBatch(
          book: book,
          totalPages: totalPages,
          startPage: 1,
          endPage: firstAiBatchEnd,
          settings: settings,
          readerReadyAfterBatch: true,
        );
        if (await _handleCancellation(book, cleanPath)) {
          return;
        }
      } else {
        state = ProcessingStatus(
          phase: ProcessingPhase.done,
          currentPage: firstAiBatchEnd,
          totalPages: totalPages,
          ocrCompletedPages: firstAiBatchEnd,
          aiCompletedPages: 0,
          readerReady: true,
        );
      }

      if (firstAiBatchEnd < totalPages) {
        await _runOcr(
          bookId: book.id,
          pdfPath: pdfPath,
          ocrPath: ocrPath,
          language: language,
          totalPages: totalPages,
          startPage: firstAiBatchEnd + 1,
          endPage: totalPages,
        );
        if (await _handleCancellation(book, cleanPath)) {
          return;
        }

        if (settings.aiMode && settings.aiApiKey.trim().isNotEmpty) {
          await _runCleanupBatch(
            book: book,
            totalPages: totalPages,
            startPage: firstAiBatchEnd + 1,
            endPage: totalPages,
            settings: settings,
            readerReadyAfterBatch: true,
          );
          if (await _handleCancellation(book, cleanPath)) {
            return;
          }
        }
      }

      final int finalAiProgress =
          settings.aiMode && settings.aiApiKey.trim().isNotEmpty
          ? totalPages
          : 0;
      await _bookRepository.updateProgress(
        id: book.id,
        ocrProgress: totalPages,
        aiProgress: finalAiProgress,
        status: BookProcessingState.ready.name,
      );
      state = ProcessingStatus(
        phase: ProcessingPhase.done,
        currentPage: totalPages,
        totalPages: totalPages,
        ocrCompletedPages: totalPages,
        aiCompletedPages: finalAiProgress,
        readerReady: true,
      );
    } catch (error) {
      final Book? book = await _bookRepository.getBook(_bookId);
      if (book != null) {
        await _bookRepository.updateProgress(
          id: _bookId,
          ocrProgress: book.ocrProgress,
          aiProgress: book.aiProgress,
          status: BookProcessingState.error.name,
        );
      }
      state = ProcessingStatus(
        phase: ProcessingPhase.error,
        currentPage: 0,
        totalPages: state.totalPages,
        ocrCompletedPages: state.ocrCompletedPages,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: state.readerReady,
        errorMessage: error.toString(),
      );
    } finally {
      await _platformChannel.destroyTesseract();
      _activeTask = null;
    }
  }

  Future<void> _runCleanupBatch({
    required Book book,
    required int totalPages,
    required int startPage,
    required int endPage,
    required AppSettings settings,
    required bool readerReadyAfterBatch,
  }) async {
    state = ProcessingStatus(
      phase: ProcessingPhase.aiCleanup,
      currentPage: startPage,
      totalPages: totalPages,
      ocrCompletedPages: state.ocrCompletedPages,
      aiCompletedPages: state.aiCompletedPages,
      readerReady: state.readerReady,
    );
    await _readerAiService.runCleanup(
      book: book,
      apiKey: settings.aiApiKey,
      geminiModel: settings.geminiModel,
      gemmaModel: settings.gemmaModel,
      startPage: startPage,
      endPage: endPage,
      shouldCancel: () => _cancelRequested,
      onProgress: (int currentPage, int totalBatchPages) async {
        if (_cancelRequested) {
          return;
        }
        final int completedInsideBatch = (currentPage - startPage) + 1;
        final int aiCompletedPages = (startPage - 1) + completedInsideBatch;
        state = ProcessingStatus(
          phase: ProcessingPhase.aiCleanup,
          currentPage: currentPage,
          totalPages: totalPages,
          ocrCompletedPages: state.ocrCompletedPages,
          aiCompletedPages: aiCompletedPages,
          readerReady:
              readerReadyAfterBatch &&
              aiCompletedPages >= (endPage < 10 ? endPage : 10),
        );
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: state.ocrCompletedPages,
          aiProgress: aiCompletedPages,
          status: BookProcessingState.processing.name,
        );
      },
    );

    final int completedBatchPages = endPage;
    state = ProcessingStatus(
      phase: ProcessingPhase.done,
      currentPage: completedBatchPages,
      totalPages: totalPages,
      ocrCompletedPages: state.ocrCompletedPages,
      aiCompletedPages: completedBatchPages,
      readerReady: readerReadyAfterBatch,
    );
    await _bookRepository.updateProgress(
      id: book.id,
      ocrProgress: state.ocrCompletedPages,
      aiProgress: completedBatchPages,
      status: completedBatchPages >= totalPages
          ? BookProcessingState.ready.name
          : BookProcessingState.processing.name,
    );
  }

  Future<bool> _handleCancellation(Book book, String cleanPath) async {
    if (!_cancelRequested) {
      return false;
    }
    switch (_cancelMode) {
      case _CancelMode.deleteBook:
        await _deleteBookAssets(book);
      case _CancelMode.keepOcr:
        await _cleanJsonManager.clear(cleanPath);
        await _cleanJsonManager.initialize(
          filePath: cleanPath,
          bookId: book.id,
        );
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: state.ocrCompletedPages,
          aiProgress: 0,
          status: BookProcessingState.ready.name,
        );
      case _CancelMode.none:
        break;
    }
    state = ProcessingStatus.idle();
    return true;
  }

  Future<void> _deleteBookAssets(Book book) async {
    final String folderPath = await _fileService.getBookFolderPath(
      book.folderName,
    );
    await _bookRepository.deleteBook(book.id);
    await _fileService.deleteBookFolder(folderPath);
  }

  Future<void> _prepareLanguage(OcrLanguage language, int totalPages) async {
    if (_cancelRequested) {
      return;
    }
    if (language.engine == OcrEngine.tesseract) {
      state = ProcessingStatus(
        phase: ProcessingPhase.downloadingLanguage,
        currentPage: 0,
        totalPages: totalPages,
        ocrCompletedPages: state.ocrCompletedPages,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: state.readerReady,
        downloadProgress: 'Preparing Tesseract data',
      );
      if (language.tessCode == null) {
        throw const LanguageDownloadException(
          'Unknown',
          'Missing Tesseract language code.',
        );
      }
      final bool available = await _platformChannel.ensureTessData(
        language.tessCode!,
      );
      if (!available) {
        throw LanguageDownloadException(
          language.displayName,
          'Tesseract language data could not be prepared.',
        );
      }
      await _platformChannel.initTesseract();
      return;
    }

    if (language.mlkitNeedsDownload && language.mlkitScript != null) {
      state = ProcessingStatus(
        phase: ProcessingPhase.downloadingLanguage,
        currentPage: 0,
        totalPages: totalPages,
        ocrCompletedPages: state.ocrCompletedPages,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: state.readerReady,
        downloadProgress: 'Preparing ML Kit language pack',
      );
      final String installStatus = await _platformChannel.ensureMlKitPackage(
        language.mlkitScript!,
      );
      if (installStatus == 'failed') {
        throw LanguageDownloadException(
          language.displayName,
          'ML Kit language pack could not be prepared.',
        );
      }
    }
  }

  Future<void> _runOcr({
    required String bookId,
    required String pdfPath,
    required String ocrPath,
    required OcrLanguage language,
    required int totalPages,
    required int startPage,
    required int endPage,
  }) async {
    for (int pageNum = startPage; pageNum <= endPage; pageNum += 1) {
      if (_cancelRequested) {
        return;
      }

      state = ProcessingStatus(
        phase: ProcessingPhase.ocr,
        currentPage: pageNum,
        totalPages: totalPages,
        ocrCompletedPages: state.ocrCompletedPages,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: state.readerReady,
      );

      final String imagePath = await _platformChannel.renderPage(
        pdfPath: pdfPath,
        pageNum: pageNum,
        dpi: AppConstants.defaultRenderDpi,
      );
      final String text = switch (language.engine) {
        OcrEngine.tesseract => await _platformChannel.recognizeWithTesseract(
          imagePath: imagePath,
          tessCode: language.tessCode!,
        ),
        OcrEngine.mlkit => await _platformChannel.recognizeWithMlKit(
          imagePath: imagePath,
          script: language.mlkitScript!,
        ),
      };

      if (_cancelRequested) {
        return;
      }

      await _ocrJsonManager.appendPage(
        filePath: ocrPath,
        page: OcrPage(
          page: pageNum,
          text: text,
          processedAt: DateTime.now().toIso8601String(),
        ),
      );
      state = ProcessingStatus(
        phase: ProcessingPhase.ocr,
        currentPage: pageNum,
        totalPages: totalPages,
        ocrCompletedPages: pageNum,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: state.readerReady,
      );
      await _bookRepository.updateProgress(
        id: bookId,
        ocrProgress: pageNum,
        aiProgress: state.aiCompletedPages,
        status: BookProcessingState.processing.name,
      );
    }
  }
}

final StateNotifierProviderFamily<PipelineNotifier, ProcessingStatus, String>
pipelineProvider =
    StateNotifierProvider.family<PipelineNotifier, ProcessingStatus, String>(
      (Ref ref, String bookId) => PipelineNotifier(ref, bookId),
    );
