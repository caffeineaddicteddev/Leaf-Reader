import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/errors.dart';
import '../data/json/clean_json_manager.dart';
import '../data/json/ocr_json_manager.dart';
import '../data/json/processing_state_manager.dart';
import '../data/repositories/book_repository.dart';
import '../domain/language_registry.dart';
import '../domain/models/book.dart';
import '../domain/models/ocr_language.dart';
import '../domain/models/ocr_page.dart';
import '../domain/models/processing_continuation_state.dart';
import '../domain/models/processing_status.dart';
import '../services/file_service.dart';
import '../services/platform/leaf_platform_channel.dart';
import '../services/reader/reader_ai_service.dart';
import 'book_providers.dart';
import 'settings_provider.dart';

enum PipelineCancelResult { none, deleted, keptOcr }

enum _CancelMode { none, deleteBook, keepOcr, disableAi }

class PipelineNotifier extends StateNotifier<ProcessingStatus> {
  PipelineNotifier(this._ref, this._bookId)
    : _bookRepository = _ref.read(bookRepositoryProvider),
      _fileService = _ref.read(fileServiceProvider),
      _platformChannel = LeafPlatformChannel(),
      _ocrJsonManager = OcrJsonManager(),
      _cleanJsonManager = CleanJsonManager(),
      _processingStateManager = ProcessingStateManager(),
      _readerAiService = ReaderAiService(),
      super(ProcessingStatus.idle());

  final Ref _ref;
  final String _bookId;
  final BookRepository _bookRepository;
  final FileService _fileService;
  final LeafPlatformChannel _platformChannel;
  final OcrJsonManager _ocrJsonManager;
  final CleanJsonManager _cleanJsonManager;
  final ProcessingStateManager _processingStateManager;
  final ReaderAiService _readerAiService;

  bool _cancelRequested = false;
  bool _disableAiRequested = false;
  _CancelMode _cancelMode = _CancelMode.none;
  Future<void>? _activeTask;

  Future<void> startPipeline() async {
    if (_activeTask != null) {
      return _activeTask;
    }
    _cancelRequested = false;
    _disableAiRequested = false;
    _cancelMode = _CancelMode.none;
    state = const ProcessingStatus(
      phase: ProcessingPhase.ocr,
      currentPage: 0,
      totalPages: 0,
      ocrCompletedPages: 0,
      aiCompletedPages: 0,
      readerReady: false,
    );
    _activeTask = _runBootstrap();
    return _activeTask;
  }

  Future<void> continueFromReader() async {
    if (_activeTask != null) {
      return _activeTask;
    }
    final Book? book = await _bookRepository.getBook(_bookId);
    if (book == null) {
      return;
    }
    final String statePath = await _fileService.getProcessingStatePath(
      book.folderName,
    );
    final ProcessingContinuationState persisted = await _processingStateManager
        .read(statePath);
    if (!persisted.bootstrapComplete || persisted.continuationMode == 'none') {
      if (!persisted.ocrPending &&
          (!persisted.aiPending || !persisted.aiEnabledForBook)) {
        return;
      }
    }
    _cancelRequested = false;
    _disableAiRequested = false;
    _cancelMode = _CancelMode.none;
    _activeTask = _runContinuation();
    return _activeTask;
  }

  Future<PipelineCancelResult> cancelPipeline() async {
    if (_activeTask == null) {
      state = ProcessingStatus.idle();
      return PipelineCancelResult.none;
    }
    _cancelRequested = true;
    final int bootstrapThreshold = state.totalPages < 10
        ? state.totalPages
        : 10;
    _cancelMode =
        state.phase == ProcessingPhase.aiCleanup ||
            state.ocrCompletedPages >= bootstrapThreshold
        ? _CancelMode.keepOcr
        : _CancelMode.deleteBook;
    await _activeTask;
    return switch (_cancelMode) {
      _CancelMode.keepOcr => PipelineCancelResult.keptOcr,
      _CancelMode.deleteBook => PipelineCancelResult.deleted,
      _CancelMode.disableAi => PipelineCancelResult.none,
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

  Future<void> setBookAiMode({required bool enabled}) async {
    final Book? book = await _bookRepository.getBook(_bookId);
    if (book == null) {
      return;
    }
    final String statePath = await _fileService.getProcessingStatePath(
      book.folderName,
    );
    ProcessingContinuationState current = await _processingStateManager.read(
      statePath,
    );
    if (current.bookId.isEmpty) {
      current = ProcessingContinuationState.initial(book.id).copyWith(
        bootstrapComplete: true,
        readerReady: true,
        continuationMode: book.ocrProgress < book.totalPages
            ? 'ocr_only'
            : 'none',
        aiEnabledForBook: enabled,
        aiCanceledByUser: !enabled,
        ocrPending: book.ocrProgress < book.totalPages,
        aiPending: book.aiProgress < book.totalPages,
        nextOcrPage: book.ocrProgress + 1,
        nextAiPage: book.aiProgress > 0 ? book.aiProgress + 1 : 1,
      );
      await _processingStateManager.write(filePath: statePath, state: current);
    }

    final bool hasRemainingAi = _hasRemainingAiWork(current, book.totalPages);
    final ProcessingContinuationState next = current.copyWith(
      aiEnabledForBook: enabled,
      aiCanceledByUser: !enabled,
      aiPending: hasRemainingAi,
    );
    await _processingStateManager.write(
      filePath: statePath,
      state: next.copyWith(continuationMode: _continuationModeForState(next)),
    );

    if (!enabled) {
      _disableAiRequested = true;
      _cancelMode = _CancelMode.disableAi;
      return;
    }

    _disableAiRequested = false;
    await continueFromReader();
  }

  Future<void> _runBootstrap() async {
    try {
      final Book? book = await _bookRepository.getBook(_bookId);
      if (book == null) {
        throw const PipelineException('Book not found.');
      }
      final AppSettings settings = await _ref.read(settingsProvider.future);
      final OcrLanguage language = LanguageRegistry.byCode(book.languageCode);
      final String pdfPath = await _fileService.getPdfPath(book);
      final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
      final String cleanPath = await _fileService.getCleanJsonPath(
        book.folderName,
      );
      final String statePath = await _fileService.getProcessingStatePath(
        book.folderName,
      );
      final int totalPages = book.totalPages > 0
          ? book.totalPages
          : await _fileService.getPageCount(pdfPath);
      final int bootstrapEnd = totalPages < 10 ? totalPages : 10;
      final bool aiEnabled =
          settings.aiMode && settings.aiApiKey.trim().isNotEmpty;

      await _ocrJsonManager.clear(ocrPath);
      await _ocrJsonManager.initialize(filePath: ocrPath, bookId: book.id);
      await _cleanJsonManager.clear(cleanPath);
      await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
      await _processingStateManager.clear(statePath);
      await _processingStateManager.initialize(
        filePath: statePath,
        bookId: book.id,
      );
      await _processingStateManager.write(
        filePath: statePath,
        state: ProcessingContinuationState.initial(book.id).copyWith(
          continuationMode: aiEnabled ? 'staged_ai' : 'ocr_only',
          aiEnabledForBook: aiEnabled,
          aiCanceledByUser: !aiEnabled,
          ocrPending: true,
          aiPending: aiEnabled,
          nextOcrPage: 1,
          nextAiPage: 1,
          nextAiCharOffset: 0,
        ),
      );
      await _bookRepository.updateProgress(
        id: book.id,
        ocrProgress: 0,
        aiProgress: 0,
        status: BookProcessingState.processing.name,
      );

      await _prepareLanguage(language, totalPages, statePath);
      if (await _handleCancellation(book, statePath)) {
        return;
      }

      await _runOcr(
        bookId: book.id,
        pdfPath: pdfPath,
        ocrPath: ocrPath,
        language: language,
        totalPages: totalPages,
        statePath: statePath,
        startPage: 1,
        endPage: bootstrapEnd,
      );
      if (await _handleCancellation(book, statePath)) {
        return;
      }

      await _processingStateManager.update(
        filePath: statePath,
        transform: (ProcessingContinuationState current) =>
            current.copyWith(nextOcrPage: bootstrapEnd + 1),
      );

      if (aiEnabled) {
        await _runBootstrapGeminiCleanup(
          book: book,
          totalPages: totalPages,
          statePath: statePath,
          settings: settings,
        );
        if (await _handleCancellation(book, statePath)) {
          return;
        }
      }

      final bool hasContinuation = bootstrapEnd < totalPages;
      final String continuationMode = aiEnabled ? 'staged_ai' : 'ocr_only';
      await _processingStateManager.update(
        filePath: statePath,
        transform: (ProcessingContinuationState current) => current.copyWith(
          bootstrapComplete: true,
          readerReady: true,
          continuationMode: hasContinuation ? continuationMode : 'none',
          aiEnabledForBook: aiEnabled,
          aiCanceledByUser: !aiEnabled,
          ocrPending: hasContinuation,
          aiPending: aiEnabled && hasContinuation,
          nextOcrPage: bootstrapEnd + 1,
          nextAiPage: aiEnabled ? current.nextAiPage : 1,
          nextAiCharOffset: aiEnabled ? current.nextAiCharOffset : 0,
          firstGeminiBatchComplete: aiEnabled,
          nativeOcrActive: false,
        ),
      );

      if (!hasContinuation) {
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: totalPages,
          aiProgress: aiEnabled ? totalPages : 0,
          status: BookProcessingState.ready.name,
        );
      }

      state = ProcessingStatus(
        phase: ProcessingPhase.done,
        currentPage: bootstrapEnd,
        totalPages: totalPages,
        ocrCompletedPages: bootstrapEnd,
        aiCompletedPages: aiEnabled ? bootstrapEnd : 0,
        readerReady: true,
      );
    } catch (error) {
      await _markBookError();
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

  Future<void> _runContinuation() async {
    try {
      final Book? book = await _bookRepository.getBook(_bookId);
      if (book == null) {
        throw const PipelineException('Book not found.');
      }
      final String pdfPath = await _fileService.getPdfPath(book);
      final String statePath = await _fileService.getProcessingStatePath(
        book.folderName,
      );
      ProcessingContinuationState continuation = await _processingStateManager
          .read(statePath);
      final int totalPages = book.totalPages;
      if (!continuation.bootstrapComplete ||
          (!continuation.ocrPending &&
              (!continuation.aiPending || !continuation.aiEnabledForBook))) {
        return;
      }

      final OcrLanguage language = LanguageRegistry.byCode(book.languageCode);
      if (continuation.ocrPending && continuation.nextOcrPage <= totalPages) {
        await _prepareLanguage(language, totalPages, statePath);
        await _runOcr(
          bookId: book.id,
          pdfPath: pdfPath,
          ocrPath: await _fileService.getOcrJsonPath(book.folderName),
          language: language,
          totalPages: totalPages,
          statePath: statePath,
          startPage: continuation.nextOcrPage,
          endPage: totalPages,
        );
        if (await _handleCancellation(book, statePath)) {
          return;
        }
        await _processingStateManager.update(
          filePath: statePath,
          transform: (ProcessingContinuationState current) => current.copyWith(
            nextOcrPage: totalPages + 1,
            ocrPending: false,
            nativeOcrActive: false,
          ),
        );
      }

      continuation = await _processingStateManager.read(statePath);
      if (continuation.aiEnabledForBook &&
          continuation.aiPending &&
          continuation.continuationMode == 'staged_ai') {
        final AppSettings settings = await _ref.read(settingsProvider.future);
        if (!continuation.firstGeminiBatchComplete) {
          await _runBootstrapGeminiCleanup(
            book: book,
            totalPages: totalPages,
            statePath: statePath,
            settings: settings,
          );
          if (await _handleCancellation(book, statePath)) {
            return;
          }
        }

        continuation = await _processingStateManager.read(statePath);
        final int gemmaStartPage = continuation.nextAiPage < 10
            ? 10
            : continuation.nextAiPage;
        final int gemmaStartCharOffset = continuation.nextAiPage <= 10
            ? continuation.nextAiCharOffset
            : 0;
        if (gemmaStartPage <= totalPages) {
          final int nextAiPage = await _runGemmaContinuation(
            book: book,
            totalPages: totalPages,
            statePath: statePath,
            startPage: gemmaStartPage,
            startCharOffset: gemmaStartCharOffset,
            settings: settings,
          );
          await _processingStateManager.update(
            filePath: statePath,
            transform: (ProcessingContinuationState current) =>
                current.copyWith(
                  nextAiPage: nextAiPage,
                  nextAiCharOffset: 0,
                  aiPending: nextAiPage <= totalPages,
                ),
          );
          if (await _handleCancellation(book, statePath)) {
            return;
          }
        }
      }

      continuation = await _processingStateManager.read(statePath);
      await _processingStateManager.update(
        filePath: statePath,
        transform: (ProcessingContinuationState current) {
          final ProcessingContinuationState next = current.copyWith(
            nextAiCharOffset: 0,
            nativeOcrActive: false,
          );
          return next.copyWith(
            continuationMode: _continuationModeForState(next),
          );
        },
      );
      continuation = await _processingStateManager.read(statePath);
      final Book? latestBook = await _bookRepository.getBook(_bookId);
      await _bookRepository.updateProgress(
        id: book.id,
        ocrProgress: totalPages,
        aiProgress:
            continuation.aiEnabledForBook &&
                continuation.continuationMode == 'none' &&
                !continuation.aiPending
            ? totalPages
            : (latestBook?.aiProgress ?? 0),
        status: continuation.continuationMode == 'none'
            ? BookProcessingState.ready.name
            : BookProcessingState.processing.name,
      );
      state = ProcessingStatus(
        phase: continuation.continuationMode == 'none'
            ? ProcessingPhase.done
            : ProcessingPhase.idle,
        currentPage: continuation.continuationMode == 'none' ? totalPages : 0,
        totalPages: totalPages,
        ocrCompletedPages: totalPages,
        aiCompletedPages:
            continuation.continuationMode == 'none' &&
                continuation.aiEnabledForBook &&
                !continuation.aiPending
            ? totalPages
            : 0,
        readerReady: true,
      );
    } catch (error) {
      await _markBookError();
      state = ProcessingStatus(
        phase: ProcessingPhase.error,
        currentPage: 0,
        totalPages: state.totalPages,
        ocrCompletedPages: state.ocrCompletedPages,
        aiCompletedPages: state.aiCompletedPages,
        readerReady: true,
        errorMessage: error.toString(),
      );
    } finally {
      await _platformChannel.destroyTesseract();
      _activeTask = null;
    }
  }

  Future<void> _runBootstrapGeminiCleanup({
    required Book book,
    required int totalPages,
    required String statePath,
    required AppSettings settings,
  }) async {
    state = ProcessingStatus(
      phase: ProcessingPhase.aiCleanup,
      currentPage: totalPages < 10 ? totalPages : 10,
      totalPages: totalPages,
      ocrCompletedPages: state.ocrCompletedPages,
      aiCompletedPages: state.aiCompletedPages,
      readerReady: state.readerReady,
    );
    final bootstrapBoundary = await _readerAiService.runBootstrapGeminiCleanup(
      book: book,
      apiKey: settings.aiApiKey,
      geminiModel: settings.geminiModel,
      shouldCancel: () => _cancelRequested || _disableAiRequested,
      onProgress: (int currentPage, int _) async {
        state = ProcessingStatus(
          phase: ProcessingPhase.aiCleanup,
          currentPage: currentPage,
          totalPages: totalPages,
          ocrCompletedPages: state.ocrCompletedPages,
          aiCompletedPages: currentPage,
          readerReady: state.readerReady,
        );
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: state.ocrCompletedPages,
          aiProgress: currentPage,
          status: BookProcessingState.processing.name,
        );
      },
    );
    await _processingStateManager.update(
      filePath: statePath,
      transform: (ProcessingContinuationState current) {
        final int nextAiPage =
            bootstrapBoundary.nextCursor.pageIndex >=
                    (state.ocrCompletedPages < 10
                        ? state.ocrCompletedPages
                        : 10)
                ? 11
                : 10;
        return current.copyWith(
          firstGeminiBatchComplete: true,
          aiPending: totalPages > 10,
          nextAiPage: nextAiPage,
          nextAiCharOffset:
              nextAiPage > 10 ? 0 : bootstrapBoundary.nextCursor.charOffset,
        );
      },
    );
  }

  Future<int> _runGemmaContinuation({
    required Book book,
    required int totalPages,
    required String statePath,
    required int startPage,
    required int startCharOffset,
    required AppSettings settings,
  }) async {
    final int nextAiPage = await _readerAiService.runGemmaContinuation(
      book: book,
      apiKey: settings.aiApiKey,
      gemmaModel: settings.gemmaModel,
      startPage: startPage,
      startCharOffset: startCharOffset,
      totalPages: totalPages,
      shouldCancel: () => _cancelRequested || _disableAiRequested,
      onProgress: (int currentPage, int _) async {
        state = ProcessingStatus(
          phase: ProcessingPhase.aiCleanup,
          currentPage: currentPage,
          totalPages: totalPages,
          ocrCompletedPages: totalPages,
          aiCompletedPages: currentPage,
          readerReady: true,
        );
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: totalPages,
          aiProgress: currentPage,
          status: BookProcessingState.processing.name,
        );
        await _processingStateManager.update(
          filePath: statePath,
          transform: (ProcessingContinuationState current) =>
              current.copyWith(nextAiPage: currentPage, nextAiCharOffset: 0),
        );
      },
    );
    return nextAiPage;
  }

  Future<bool> _handleCancellation(Book book, String statePath) async {
    if (!_cancelRequested && !_disableAiRequested) {
      return false;
    }
    final ProcessingContinuationState current = await _processingStateManager
        .read(statePath);
    switch (_cancelMode) {
      case _CancelMode.deleteBook:
        await _deleteBookAssets(book);
        break;
      case _CancelMode.keepOcr:
        await _processingStateManager.write(
          filePath: statePath,
          state: current.copyWith(
            bootstrapComplete: true,
            readerReady: true,
            aiEnabledForBook: false,
            aiCanceledByUser: true,
            ocrPending: state.ocrCompletedPages < book.totalPages,
            aiPending: _hasRemainingAiWork(current, book.totalPages),
            continuationMode: state.ocrCompletedPages < book.totalPages
                ? 'ocr_only'
                : _continuationModeForState(
                    current.copyWith(
                      aiEnabledForBook: false,
                      aiCanceledByUser: true,
                      ocrPending: false,
                      aiPending: _hasRemainingAiWork(current, book.totalPages),
                    ),
                  ),
            nextOcrPage: state.ocrCompletedPages + 1,
            nextAiPage: current.firstGeminiBatchComplete
                ? current.nextAiPage
                : 1,
            nextAiCharOffset: current.nextAiCharOffset,
            nativeOcrActive: false,
          ),
        );
        await _bookRepository.updateProgress(
          id: book.id,
          ocrProgress: state.ocrCompletedPages,
          aiProgress: state.aiCompletedPages,
          status: BookProcessingState.processing.name,
        );
        break;
      case _CancelMode.disableAi:
        final ProcessingContinuationState next = current.copyWith(
          bootstrapComplete: true,
          readerReady: true,
          aiEnabledForBook: false,
          aiCanceledByUser: true,
          aiPending: _hasRemainingAiWork(current, book.totalPages),
          nativeOcrActive: false,
        );
        await _processingStateManager.write(
          filePath: statePath,
          state: next.copyWith(
            continuationMode: _continuationModeForState(next),
          ),
        );
        break;
      case _CancelMode.none:
        break;
    }
    state = ProcessingStatus.idle();
    _cancelRequested = false;
    _disableAiRequested = false;
    return true;
  }

  Future<void> _deleteBookAssets(Book book) async {
    final String folderPath = await _fileService.getBookFolderPath(
      book.folderName,
    );
    await _bookRepository.deleteBook(book.id);
    await _fileService.deleteBookFolder(folderPath);
  }

  Future<void> _prepareLanguage(
    OcrLanguage language,
    int totalPages,
    String statePath,
  ) async {
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
      await _processingStateManager.update(
        filePath: statePath,
        transform: (ProcessingContinuationState current) =>
            current.copyWith(nativeOcrActive: true),
      );
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
    required String statePath,
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
      await _processingStateManager.update(
        filePath: statePath,
        transform: (ProcessingContinuationState current) =>
            current.copyWith(nextOcrPage: pageNum + 1),
      );
    }
  }

  Future<void> _markBookError() async {
    final Book? book = await _bookRepository.getBook(_bookId);
    if (book != null) {
      await _bookRepository.updateProgress(
        id: _bookId,
        ocrProgress: book.ocrProgress,
        aiProgress: book.aiProgress,
        status: BookProcessingState.error.name,
      );
    }
  }

  bool _hasRemainingAiWork(ProcessingContinuationState state, int totalPages) {
    return !state.firstGeminiBatchComplete || state.nextAiPage <= totalPages;
  }

  String _continuationModeForState(ProcessingContinuationState state) {
    if (state.aiPending) {
      return 'staged_ai';
    }
    if (state.ocrPending) {
      return state.aiEnabledForBook ? 'staged_ai' : 'ocr_only';
    }
    return 'none';
  }
}

final StateNotifierProviderFamily<PipelineNotifier, ProcessingStatus, String>
pipelineProvider =
    StateNotifierProvider.family<PipelineNotifier, ProcessingStatus, String>(
      (Ref ref, String bookId) => PipelineNotifier(ref, bookId),
    );
