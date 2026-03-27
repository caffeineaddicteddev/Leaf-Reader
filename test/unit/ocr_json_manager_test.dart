import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/data/json/ocr_json_manager.dart';
import 'package:leaf_flutter/domain/models/ocr_page.dart';

void main() {
  late Directory tempDir;
  late OcrJsonManager manager;
  late String filePath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('leaf_ocr_test');
    manager = OcrJsonManager();
    filePath = '${tempDir.path}/book_ocr.json';
    await manager.initialize(filePath: filePath, bookId: 'book-1');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('appendPage and readPages', () async {
    await manager.appendPage(
      filePath: filePath,
      page: const OcrPage(page: 1, text: 'Hello', processedAt: 'now'),
    );

    final pages = await manager.readPages(filePath);
    expect(pages.length, 1);
    expect(pages.first.text, 'Hello');
  });

  test('getPage returns matching page', () async {
    await manager.appendPage(
      filePath: filePath,
      page: const OcrPage(page: 2, text: 'Second', processedAt: 'now'),
    );

    final page = await manager.getPage(filePath: filePath, pageNumber: 2);
    expect(page?.text, 'Second');
  });

  test('pageCount returns number of pages', () async {
    await manager.appendPage(
      filePath: filePath,
      page: const OcrPage(page: 1, text: 'One', processedAt: 'now'),
    );
    await manager.appendPage(
      filePath: filePath,
      page: const OcrPage(page: 2, text: 'Two', processedAt: 'now'),
    );

    expect(await manager.pageCount(filePath), 2);
  });
}
