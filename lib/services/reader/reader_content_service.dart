import '../../data/json/clean_json_manager.dart';
import '../../data/json/ocr_json_manager.dart';
import '../../domain/models/book.dart';
import '../../domain/models/clean_page.dart';
import '../../domain/models/ocr_page.dart';
import '../file_service.dart';

class ReaderBlock {
  const ReaderBlock({
    required this.page,
    required this.text,
    required this.aiCorrected,
  });

  final int page;
  final String text;
  final bool aiCorrected;
}

class ReaderContentService {
  ReaderContentService({
    FileService? fileService,
    OcrJsonManager? ocrJsonManager,
    CleanJsonManager? cleanJsonManager,
  }) : _fileService = fileService ?? FileService(),
       _ocrJsonManager = ocrJsonManager ?? OcrJsonManager(),
       _cleanJsonManager = cleanJsonManager ?? CleanJsonManager();

  final FileService _fileService;
  final OcrJsonManager _ocrJsonManager;
  final CleanJsonManager _cleanJsonManager;

  Future<List<ReaderBlock>> loadContent({
    required Book book,
    required bool preferAi,
  }) async {
    final String ocrPath = await _fileService.getOcrJsonPath(book.folderName);
    final String cleanPath = await _fileService.getCleanJsonPath(
      book.folderName,
    );
    final List<OcrPage> ocrPages = await _ocrJsonManager.readPages(ocrPath);
    if (!preferAi) {
      return ocrPages
          .map(
            (OcrPage page) => ReaderBlock(
              page: page.page,
              text: page.text,
              aiCorrected: false,
            ),
          )
          .toList(growable: false);
    }

    final List<CleanPage> cleanPages = await _cleanJsonManager.readPages(
      cleanPath,
    );
    final Map<int, CleanPage> cleanByPage = <int, CleanPage>{};
    for (final CleanPage cleanPage in cleanPages) {
      cleanByPage[cleanPage.page] = cleanPage;
    }

    return ocrPages
        .map((OcrPage ocrPage) {
          final CleanPage? cleanPage = cleanByPage[ocrPage.page];
          return ReaderBlock(
            page: ocrPage.page,
            text: cleanPage?.text.isNotEmpty == true
                ? cleanPage!.text
                : ocrPage.text,
            aiCorrected: cleanPage?.text.isNotEmpty == true,
          );
        })
        .toList(growable: false);
  }
}
