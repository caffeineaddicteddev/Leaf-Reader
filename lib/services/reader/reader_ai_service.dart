import 'dart:async';

import '../../data/json/clean_json_manager.dart';
import '../../data/json/ocr_json_manager.dart';
import '../../domain/language_registry.dart';
import '../../domain/models/book.dart';
import '../../domain/models/clean_page.dart';
import '../file_service.dart';
import '../pipeline/ai_client.dart';
import '../pipeline/promptizer.dart';

class ReaderAiService {
  ReaderAiService({
    FileService? fileService,
    OcrJsonManager? ocrJsonManager,
    CleanJsonManager? cleanJsonManager,
    AiClient? aiClient,
    Promptizer? promptizer,
  }) : _fileService = fileService ?? FileService(),
       _ocrJsonManager = ocrJsonManager ?? OcrJsonManager(),
       _cleanJsonManager = cleanJsonManager ?? CleanJsonManager(),
       _aiClient = aiClient ?? AiClient(),
       _promptizer = promptizer ?? const Promptizer();

  final FileService _fileService;
  final OcrJsonManager _ocrJsonManager;
  final CleanJsonManager _cleanJsonManager;
  final AiClient _aiClient;
  final Promptizer _promptizer;

  Future<void> runCleanup({
    required Book book,
    required String apiKey,
    required String geminiModel,
    required String gemmaModel,
    int? startPage,
    int? endPage,
    bool Function()? shouldCancel,
    FutureOr<void> Function(int currentPage, int totalPages)? onProgress,
  }) async {
    final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
    final String cleanPath = await _fileService.getCleanJsonPath(
      book.folderName,
    );
    final pages = (await _ocrJsonManager.readPages(ocrPath))
        .where((page) {
          if (startPage != null && page.page < startPage) {
            return false;
          }
          if (endPage != null && page.page > endPage) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
    await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
    final language = LanguageRegistry.byCode(book.languageCode);
    final int totalPages = pages.length;

    if (pages.isEmpty) {
      return;
    }

    final bool isGeminiBatch =
        startPage != null &&
        startPage == 1 &&
        endPage != null &&
        endPage <= 10 &&
        pages.length > 1;
    if (isGeminiBatch) {
      await onProgress?.call(endPage, totalPages);
      final List<int> sourcePages = pages
          .map((page) => page.page)
          .toList(growable: false);
      final String combinedOcr = pages
          .map((page) => '[Page ${page.page}]\n${page.text}')
          .join('\n\n');
      final String cleanedText = combinedOcr.trim().isEmpty
          ? ''
          : await _aiClient.cleanChunk(
              pageNumber: 1,
              prompt: _promptizer.geminiPrompt(
                languageDisplayName: language.displayName,
                ocrText: combinedOcr,
              ),
              apiKey: apiKey,
              geminiModel: geminiModel,
              geminiFallbackModels: const <String>[
                'gemini-3.1-flash-lite-preview',
                'gemini-2.5-flash',
              ],
              gemmaModels: <String>[gemmaModel, 'gemma-3-12b-it'],
            );
      await _cleanJsonManager.appendPage(
        filePath: cleanPath,
        page: CleanPage(
          page: endPage,
          text: cleanedText,
          sourcePages: sourcePages,
          modelUsed: geminiModel,
          processedAt: DateTime.now().toIso8601String(),
        ),
      );
      return;
    }

    for (final page in pages) {
      if (shouldCancel?.call() == true) {
        return;
      }
      await onProgress?.call(page.page, totalPages);
      if (page.text.trim().isEmpty) {
        await _cleanJsonManager.appendPage(
          filePath: cleanPath,
          page: CleanPage(
            page: page.page,
            text: '',
            sourcePages: <int>[page.page],
            modelUsed: 'raw-ocr',
            processedAt: DateTime.now().toIso8601String(),
          ),
        );
        continue;
      }
      final String prompt = page.page <= 10
          ? _promptizer.geminiPrompt(
              languageDisplayName: language.displayName,
              ocrText: page.text,
            )
          : _promptizer.gemmaPrompt(
              languageDisplayName: language.displayName,
              ocrText: page.text,
            );
      final String cleanedText = await _aiClient.cleanChunk(
        pageNumber: page.page,
        prompt: prompt,
        apiKey: apiKey,
        geminiModel: geminiModel,
        geminiFallbackModels: const <String>[
          'gemini-3.1-flash-lite-preview',
          'gemini-2.5-flash',
        ],
        gemmaModels: <String>[gemmaModel, 'gemma-3-12b-it'],
      );
      await _cleanJsonManager.appendPage(
        filePath: cleanPath,
        page: CleanPage(
          page: page.page,
          text: cleanedText,
          sourcePages: <int>[page.page],
          modelUsed: page.page <= 10 ? geminiModel : gemmaModel,
          processedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }
}
