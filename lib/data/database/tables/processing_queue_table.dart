import 'package:drift/drift.dart';

class ProcessingQueue extends Table {
  TextColumn get id => text()();

  TextColumn get bookId => text().named('book_id')();

  IntColumn get currentPage =>
      integer().named('current_page').withDefault(const Constant(0))();

  TextColumn get phase => text().withDefault(const Constant('ocr'))();

  TextColumn get status => text().withDefault(const Constant('queued'))();

  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
