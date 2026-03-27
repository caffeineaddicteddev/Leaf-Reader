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
  }) async {
    final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
    final String cleanPath = await _fileService.getCleanJsonPath(
      book.folderName,
    );
    final pages = await _ocrJsonManager.readPages(ocrPath);
    await _cleanJsonManager.initialize(filePath: cleanPath, bookId: book.id);
    final language = LanguageRegistry.byCode(book.languageCode);

    for (final page in pages) {
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
        gemmaModels: <String>[gemmaModel, 'gemma-3-12b-it', 'gemma-3-4b-it'],
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
