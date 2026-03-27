import '../../data/json/clean_json_manager.dart';
import '../../data/json/ocr_json_manager.dart';
import '../../domain/models/book.dart';
import '../../domain/models/clean_page.dart';
import '../../domain/models/ocr_page.dart';
import '../file_service.dart';

class ReaderBlock {
  const ReaderBlock({
    required this.pageLabel,
    required this.text,
    required this.aiCorrected,
    required this.sourcePages,
  });

  final String pageLabel;
  final String text;
  final bool aiCorrected;
  final List<int> sourcePages;
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
              pageLabel: 'Page ${page.page}',
              text: page.text,
              aiCorrected: false,
              sourcePages: <int>[page.page],
            ),
          )
          .toList(growable: false);
    }

    final List<CleanPage> cleanPages = await _cleanJsonManager.readPages(
      cleanPath,
    );
    final Set<int> coveredPages = <int>{};
    final List<ReaderBlock> blocks = <ReaderBlock>[];

    for (final CleanPage cleanPage in cleanPages) {
      if (cleanPage.text.trim().isEmpty || cleanPage.sourcePages.isEmpty) {
        continue;
      }
      coveredPages.addAll(cleanPage.sourcePages);
      final List<int> sourcePages = List<int>.from(cleanPage.sourcePages)
        ..sort();
      final String pageLabel = sourcePages.length == 1
          ? 'Page ${sourcePages.first}'
          : 'Pages ${sourcePages.first}-${sourcePages.last}';
      blocks.add(
        ReaderBlock(
          pageLabel: pageLabel,
          text: cleanPage.text,
          aiCorrected: true,
          sourcePages: sourcePages,
        ),
      );
    }

    for (final OcrPage ocrPage in ocrPages) {
      if (coveredPages.contains(ocrPage.page)) {
        continue;
      }
      blocks.add(
        ReaderBlock(
          pageLabel: 'Page ${ocrPage.page}',
          text: ocrPage.text,
          aiCorrected: false,
          sourcePages: <int>[ocrPage.page],
        ),
      );
    }

    return blocks;
  }
}
