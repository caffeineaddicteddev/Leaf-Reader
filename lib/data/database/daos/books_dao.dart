import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/books_table.dart';

part 'books_dao.g.dart';

@DriftAccessor(tables: <Type>[Books])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.attachedDatabase);

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Future<Book?> getBook(String id) {
    return (select(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<List<Book>> getAllBooks() => select(books).get();

  Future<void> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<void> updateBookEntry(Book book) => update(books).replace(book);

  Future<void> updateMetadata({
    required String id,
    required String name,
    required String author,
  }) {
    return (update(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).write(
      BooksCompanion(
        name: Value<String>(name),
        author: Value<String>(author),
        updatedAt: Value<String>(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> deleteBookById(String id) {
    return (delete(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).go();
  }

  Future<void> updateProgress({
    required String id,
    required int ocrProgress,
    required int aiProgress,
    required String status,
  }) {
    return (update(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).write(
      BooksCompanion(
        ocrProgress: Value<int>(ocrProgress),
        aiProgress: Value<int>(aiProgress),
        status: Value<String>(status),
        updatedAt: Value<String>(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> updateLastReadPage({
    required String id,
    required int lastReadPage,
  }) {
    return (update(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).write(
      BooksCompanion(
        lastReadPage: Value<int>(lastReadPage),
        updatedAt: Value<String>(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> updateCoverPath({
    required String id,
    required String? coverPath,
  }) {
    return (update(
      books,
    )..where(($BooksTable table) => table.id.equals(id))).write(
      BooksCompanion(
        coverPath: Value<String?>(coverPath),
        updatedAt: Value<String>(DateTime.now().toIso8601String()),
      ),
    );
  }
}
