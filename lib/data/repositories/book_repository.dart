import '../../domain/models/book.dart' as domain;
import '../../domain/models/processing_status.dart';
import '../database/app_database.dart';

class BookRepository {
  const BookRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.Book>> watchAllBooks() {
    return _database.booksDao.watchAllBooks().map(
      (List<Book> rows) => rows.map(_mapBook).toList(growable: false),
    );
  }

  Stream<domain.Book?> watchBook(String id) {
    return _database.booksDao.watchBook(id).map(
      (Book? row) => row == null ? null : _mapBook(row),
    );
  }

  Future<domain.Book?> getBook(String id) async {
    final Book? row = await _database.booksDao.getBook(id);
    return row == null ? null : _mapBook(row);
  }

  Future<List<domain.Book>> getAllBooks() async {
    final List<Book> rows = await _database.booksDao.getAllBooks();
    return rows.map(_mapBook).toList(growable: false);
  }

  Future<void> insertBook(BooksCompanion book) =>
      _database.booksDao.insertBook(book);

  Future<void> updateBook(Book book) =>
      _database.booksDao.updateBookEntry(book);

  Future<void> updateMetadata({
    required String id,
    required String name,
    required String author,
  }) {
    return _database.booksDao.updateMetadata(
      id: id,
      name: name,
      author: author,
    );
  }

  Future<void> deleteBook(String id) => _database.booksDao.deleteBookById(id);

  Future<void> updateCoverPath({
    required String id,
    required String? coverPath,
  }) {
    return _database.booksDao.updateCoverPath(id: id, coverPath: coverPath);
  }

  Future<void> updateProgress({
    required String id,
    required int ocrProgress,
    required int aiProgress,
    required String status,
  }) {
    return _database.booksDao.updateProgress(
      id: id,
      ocrProgress: ocrProgress,
      aiProgress: aiProgress,
      status: status,
    );
  }

  Future<void> updateLastReadPage({
    required String id,
    required int lastReadPage,
  }) {
    return _database.booksDao.updateLastReadPage(
      id: id,
      lastReadPage: lastReadPage,
    );
  }

  Future<void> updateLastScrollOffset({
    required String id,
    required double lastScrollOffset,
  }) {
    return _database.booksDao.updateLastScrollOffset(
      id: id,
      lastScrollOffset: lastScrollOffset,
    );
  }

  domain.Book _mapBook(Book row) {
    return domain.Book(
      id: row.id,
      name: row.name,
      author: row.author,
      folderName: row.folderName,
      pdfFilename: row.pdfFilename,
      coverPath: row.coverPath,
      totalPages: row.totalPages,
      ocrProgress: row.ocrProgress,
      aiProgress: row.aiProgress,
      lastReadPage: row.lastReadPage,
      lastScrollOffset: row.lastScrollOffset,
      languageCode: row.languageCode,
      status: BookProcessingState.values.firstWhere(
        (BookProcessingState state) => state.name == row.status,
        orElse: () => BookProcessingState.pending,
      ),
      fileSize: row.fileSize,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }
}
