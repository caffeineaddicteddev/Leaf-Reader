import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/book_repository.dart';
import '../domain/models/book.dart';
import '../services/file_service.dart';
import 'database_provider.dart';

final Provider<BookRepository> bookRepositoryProvider =
    Provider<BookRepository>((Ref ref) {
      return BookRepository(ref.watch(databaseProvider));
    });

final StreamProvider<List<Book>> booksProvider = StreamProvider<List<Book>>((
  Ref ref,
) {
  return ref.watch(bookRepositoryProvider).watchAllBooks();
});

final Provider<FileService> fileServiceProvider = Provider<FileService>((
  Ref ref,
) {
  return FileService();
});

final bookProvider = FutureProvider.family<Book?, String>((
  Ref ref,
  String bookId,
) {
  return ref.watch(bookRepositoryProvider).getBook(bookId);
});
