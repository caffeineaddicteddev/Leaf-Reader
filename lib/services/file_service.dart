import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import '../core/extensions.dart';
import '../domain/models/book.dart';
import 'platform/leaf_platform_channel.dart';

class FileService {
  FileService({
    LeafPlatformChannel? platformChannel,
    Future<Directory> Function()? documentsDirectoryProvider,
    Future<Directory> Function()? temporaryDirectoryProvider,
  }) : _platformChannel = platformChannel ?? LeafPlatformChannel(),
       _documentsDirectoryProvider =
           documentsDirectoryProvider ?? getApplicationDocumentsDirectory,
       _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory;

  final LeafPlatformChannel _platformChannel;
  final Future<Directory> Function() _documentsDirectoryProvider;
  final Future<Directory> Function() _temporaryDirectoryProvider;

  Future<String> createBookFolder(String bookName, String uuid) async {
    final Directory root = await _libraryRoot();
    final String folderName = '${bookName.toFolderSlug()}_$uuid';
    final Directory folder = Directory(p.join(root.path, folderName));
    await folder.create(recursive: true);
    return folder.path;
  }

  Future<String> copyPdfToFolder({
    required String sourcePath,
    required String folderPath,
    required String originalFilename,
  }) async {
    final File copiedFile = await File(
      sourcePath,
    ).copy(p.join(folderPath, originalFilename));
    return copiedFile.path;
  }

  Future<void> deleteBookFolder(String folderPath) async {
    final Directory folder = Directory(folderPath);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }

  Future<String> generateCover({
    required String pdfPath,
    required String folderPath,
  }) async {
    final String renderedPath = await _platformChannel.renderPage(
      pdfPath: pdfPath,
      pageNum: 1,
      dpi: 72,
    );
    final File cover = await File(
      renderedPath,
    ).copy(p.join(folderPath, 'cover.png'));
    return cover.path;
  }

  Future<int> getPageCount(String pdfPath) {
    return _platformChannel.getPageCount(pdfPath);
  }

  Future<String> getBookFolderPath(String folderName) async {
    final Directory root = await _libraryRoot();
    return p.join(root.path, folderName);
  }

  Future<String> getOcrJsonPath(String folderName) async {
    return p.join(
      await getBookFolderPath(folderName),
      AppConstants.ocrJsonFileName,
    );
  }

  Future<String> getCleanJsonPath(String folderName) async {
    return p.join(
      await getBookFolderPath(folderName),
      AppConstants.cleanJsonFileName,
    );
  }

  Future<String> getPdfPath(Book book) async {
    return p.join(await getBookFolderPath(book.folderName), book.pdfFilename);
  }

  Future<int> getLibrarySize() async {
    final Directory root = await _libraryRoot();
    if (!await root.exists()) {
      return 0;
    }
    int total = 0;
    await for (final FileSystemEntity entity in root.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> clearCache() async {
    final Directory temporaryDirectory = await _temporaryDirectoryProvider();
    await for (final FileSystemEntity entity in temporaryDirectory.list(
      recursive: false,
      followLinks: false,
    )) {
      if (entity is File && p.basename(entity.path).startsWith('leaf_p')) {
        await entity.delete();
      }
    }
  }

  Future<Directory> _libraryRoot() async {
    final Directory documentsDirectory = await _documentsDirectoryProvider();
    final Directory root = Directory(
      p.join(documentsDirectory.path, AppConstants.libraryFolderName),
    );
    await root.create(recursive: true);
    return root;
  }
}
