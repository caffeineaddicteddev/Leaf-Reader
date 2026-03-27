import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/services/file_service.dart';

void main() {
  late Directory tempDir;
  late FileService fileService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('leaf_file_test');
    fileService = FileService(
      documentsDirectoryProvider: () async => tempDir,
      temporaryDirectoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('createBookFolder creates folder', () async {
    final folderPath = await fileService.createBookFolder('My Book', '123');
    expect(await Directory(folderPath).exists(), isTrue);
  });

  test('deleteBookFolder deletes folder recursively', () async {
    final folderPath = await fileService.createBookFolder('My Book', '123');
    await File('$folderPath/test.txt').writeAsString('hello');

    await fileService.deleteBookFolder(folderPath);

    expect(await Directory(folderPath).exists(), isFalse);
  });
}
