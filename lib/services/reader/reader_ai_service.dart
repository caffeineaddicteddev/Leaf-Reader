import 'dart:async';

import '../../data/json/clean_json_manager.dart';
import '../../data/json/ocr_json_manager.dart';
import '../../domain/language_registry.dart';
import '../../domain/models/book.dart';
import '../../domain/models/clean_page.dart';
import '../../domain/models/ocr_page.dart';
import '../file_service.dart';
import '../pipeline/ai_client.dart';
import '../pipeline/promptizer.dart';
import '../pipeline/tokenizer.dart';

class ReaderAiService {
  ReaderAiService({
    FileService? fileService,
    OcrJsonManager? ocrJsonManager,
    CleanJsonManager? cleanJsonManager,
    AiClient? aiClient,
    Promptizer? promptizer,
    Tokenizer? tokenizer,
    Future<void> Function(Duration duration)? delay,
  }) : _fileService = fileService ?? FileService(),
       _ocrJsonManager = ocrJsonManager ?? OcrJsonManager(),
       _cleanJsonManager = cleanJsonManager ?? CleanJsonManager(),
       _aiClient = aiClient ?? AiClient(),
       _promptizer = promptizer ?? const Promptizer(),
       _tokenizer = tokenizer ?? const Tokenizer(),
       _delay = delay ?? Future<void>.delayed;

  final FileService _fileService;
  final OcrJsonManager _ocrJsonManager;
  final CleanJsonManager _cleanJsonManager;
  final AiClient _aiClient;
  final Promptizer _promptizer;
  final Tokenizer _tokenizer;
  final Future<void> Function(Duration duration) _delay;

  Future<TokenizerCursor> runBootstrapGeminiCleanup({
    required Book book,
    required String apiKey,
    required String geminiModel,
    bool Function()? shouldCancel,
    FutureOr<void> Function(int currentPage, int totalPages)? onProgress,
  }) async {
    final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
    final String cleanPath = await _fileService.getCleanJsonPath(
      book.folderName,
    );
    final List<OcrPage> pages = (await _ocrJsonManager.readPages(
      ocrPath,
    )).where((OcrPage page) => page.page <= 10).toList(growable: false);
    if (pages.isEmpty || shouldCancel?.call() == true) {
      return const TokenizerCursor(pageIndex: 0, charOffset: 0);
    }
    await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
    final TokenizerBoundary boundary = _tokenizer.splitAtLastSentenceBoundary(
      pages: pages,
    );
    await onProgress?.call(pages.length, book.totalPages);
    final language = LanguageRegistry.byCode(book.languageCode);
    final String cleanedText = boundary.chunk.trim().isEmpty
        ? ''
        : await _aiClient.cleanChunk(
            pageNumber: 1,
            prompt: _promptizer.geminiPrompt(
              languageDisplayName: language.displayName,
              ocrText: boundary.chunk,
            ),
            apiKey: apiKey,
            geminiModel: geminiModel,
            geminiFallbackModels: const <String>[
              'gemini-3.1-flash-lite-preview',
              'gemini-2.5-flash',
            ],
          );
    if (shouldCancel?.call() == true) {
      return boundary.nextCursor;
    }
    await _cleanJsonManager.appendPage(
      filePath: cleanPath,
      page: CleanPage(
        page: pages.last.page,
        text: cleanedText,
        sourcePages: boundary.sourcePages,
        modelUsed: geminiModel,
        processedAt: DateTime.now().toIso8601String(),
      ),
    );
    return boundary.nextCursor;
  }

  Future<int> runGemmaContinuation({
    required Book book,
    required String apiKey,
    required String gemmaModel,
    required int startPage,
    required int startCharOffset,
    required int totalPages,
    bool Function()? shouldCancel,
    FutureOr<void> Function(int currentPage, int totalPages)? onProgress,
  }) async {
    final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
    final String cleanPath = await _fileService.getCleanJsonPath(
      book.folderName,
    );
    final List<OcrPage> allPages = await _ocrJsonManager.readPages(ocrPath);
    final List<OcrPage> pages = allPages
        .where((OcrPage page) => page.page >= startPage)
        .toList(growable: false);
    if (pages.isEmpty) {
      return startPage;
    }
    await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
    final language = LanguageRegistry.byCode(book.languageCode);
    TokenizerCursor cursor = TokenizerCursor(
      pageIndex: 0,
      charOffset: startCharOffset,
    );
    int nextAiPage = startPage;
    bool firstChunk = true;

    while (true) {
      if (shouldCancel?.call() == true) {
        return nextAiPage;
      }
      if (!firstChunk) {
        await _delay(const Duration(seconds: 10));
      }
      final TokenizerResult? result = _tokenizer.nextChunk(
        pages: pages,
        cursor: cursor,
      );
      if (result == null) {
        return totalPages + 1;
      }
      final int currentStartPage = result.sourcePages.first;
      await onProgress?.call(currentStartPage, totalPages);
      final String cleanedText = result.chunk.trim().isEmpty
          ? ''
          : await _aiClient.cleanChunk(
              pageNumber: currentStartPage,
              prompt: _promptizer.gemmaPrompt(
                languageDisplayName: language.displayName,
                ocrText: result.chunk,
              ),
              apiKey: apiKey,
              gemmaModels: <String>[gemmaModel, 'gemma-3-12b-it'],
            );
      if (shouldCancel?.call() == true) {
        return currentStartPage;
      }
      await _cleanJsonManager.appendPage(
        filePath: cleanPath,
        page: CleanPage(
          page: currentStartPage,
          text: cleanedText,
          sourcePages: result.sourcePages,
          modelUsed: gemmaModel,
          processedAt: DateTime.now().toIso8601String(),
        ),
      );
      cursor = result.nextCursor;
      nextAiPage = result.nextCursor.pageIndex >= pages.length
          ? totalPages + 1
          : pages[result.nextCursor.pageIndex].page;
      firstChunk = false;
    }
  }
}
