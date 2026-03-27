import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/models/clean_page.dart';
import 'json_mutex.dart';

class CleanJsonManager {
  CleanJsonManager({JsonMutex? mutex, Duration? pollingInterval})
    : _mutex = mutex ?? JsonMutex(),
      _pollingInterval = pollingInterval ?? const Duration(seconds: 2);

  final JsonMutex _mutex;
  final Duration _pollingInterval;

  Future<void> initialize({required String filePath, required String bookId}) {
    return _mutex.protect(() async {
      final File file = File(filePath);
      if (await file.exists()) {
        return;
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(<String, Object?>{'bookId': bookId, 'pages': <Object?>[]}),
      );
    });
  }

  Future<void> appendPage({required String filePath, required CleanPage page}) {
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
        'sourcePages': page.sourcePages,
        'modelUsed': page.modelUsed,
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

  Future<List<CleanPage>> readPages(String filePath) async {
    final Map<String, Object?> root = await _readRoot(filePath);
    final List<Object?> rawPages =
        (root['pages'] as List<Object?>?) ?? <Object?>[];
    return rawPages.map(_pageFromJson).toList(growable: false);
  }

  Stream<List<CleanPage>> watchPages(String filePath) async* {
    List<CleanPage> previous = <CleanPage>[];
    while (true) {
      final List<CleanPage> current = await readPages(filePath);
      if (!_isSame(previous, current)) {
        previous = current;
        yield current;
      }
      await Future<void>.delayed(_pollingInterval);
    }
  }

  Future<int> pageCount(String filePath) async =>
      (await readPages(filePath)).length;

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

  CleanPage _pageFromJson(Object? raw) {
    final Map<String, Object?> json = (raw as Map<Object?, Object?>)
        .cast<String, Object?>();
    final List<Object?> rawSourcePages =
        (json['sourcePages'] as List<Object?>?) ?? <Object?>[];
    return CleanPage(
      page: json['page'] as int,
      text: json['text'] as String? ?? '',
      sourcePages: rawSourcePages
          .map((Object? item) => item as int)
          .toList(growable: false),
      modelUsed: json['modelUsed'] as String? ?? '',
      processedAt: json['processedAt'] as String? ?? '',
    );
  }

  bool _isSame(List<CleanPage> left, List<CleanPage> right) {
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      final CleanPage leftPage = left[index];
      final CleanPage rightPage = right[index];
      if (leftPage.page != rightPage.page ||
          leftPage.text != rightPage.text ||
          leftPage.modelUsed != rightPage.modelUsed ||
          leftPage.processedAt != rightPage.processedAt) {
        return false;
      }
    }
    return true;
  }
}
