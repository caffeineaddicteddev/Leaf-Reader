import 'dart:convert';
import 'dart:io';

import '../../domain/models/ocr_page.dart';
import 'json_mutex.dart';

class OcrJsonManager {
  OcrJsonManager({JsonMutex? mutex}) : _mutex = mutex ?? JsonMutex();

  final JsonMutex _mutex;

  Future<void> initialize({required String filePath, required String bookId}) {
    return _mutex.protect(() async {
      final File file = File(filePath);
      if (await file.exists()) {
        return;
      }
      await file.parent.create(recursive: true);
      final Map<String, Object?> payload = <String, Object?>{
        'bookId': bookId,
        'pages': <Object?>[],
      };
      await file.writeAsString(jsonEncode(payload));
    });
  }

  Future<void> appendPage({required String filePath, required OcrPage page}) {
    return _mutex.protect(() async {
      final Map<String, Object?> root = await _readRoot(filePath);
      final List<Object?> pages =
          (root['pages'] as List<Object?>?) ?? <Object?>[];
      pages.removeWhere(
        (Object? item) => (item as Map<String, Object?>)['page'] == page.page,
      );
      pages.add(<String, Object?>{
        'page': page.page,
        'text': page.text,
        'processedAt': page.processedAt,
      });
      pages.sort((Object? left, Object? right) {
        final int leftPage = (left as Map<String, Object?>)['page'] as int;
        final int rightPage = (right as Map<String, Object?>)['page'] as int;
        return leftPage.compareTo(rightPage);
      });
      root['pages'] = pages;
      await File(filePath).writeAsString(jsonEncode(root));
    });
  }

  Future<List<OcrPage>> readPages(String filePath) async {
    final Map<String, Object?> root = await _readRoot(filePath);
    final List<Object?> rawPages =
        (root['pages'] as List<Object?>?) ?? <Object?>[];
    return rawPages.map(_pageFromJson).toList(growable: false);
  }

  Future<OcrPage?> getPage({
    required String filePath,
    required int pageNumber,
  }) async {
    final List<OcrPage> pages = await readPages(filePath);
    for (final OcrPage page in pages) {
      if (page.page == pageNumber) {
        return page;
      }
    }
    return null;
  }

  Future<int> pageCount(String filePath) async {
    final List<OcrPage> pages = await readPages(filePath);
    return pages.length;
  }

  Future<void> clear(String filePath) {
    return _mutex.protect(() async {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    });
  }

  Future<Map<String, Object?>> _readRoot(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      return <String, Object?>{'pages': <Object?>[]};
    }
    final String content = await file.readAsString();
    if (content.trim().isEmpty) {
      return <String, Object?>{'pages': <Object?>[]};
    }
    return (jsonDecode(content) as Map<Object?, Object?>)
        .cast<String, Object?>();
  }

  OcrPage _pageFromJson(Object? raw) {
    final Map<String, Object?> json = (raw as Map<Object?, Object?>)
        .cast<String, Object?>();
    return OcrPage(
      page: json['page'] as int,
      text: json['text'] as String? ?? '',
      processedAt: json['processedAt'] as String? ?? '',
    );
  }
}
