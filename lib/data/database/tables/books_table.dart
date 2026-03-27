import 'package:drift/drift.dart';

class Books extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get author => text().withDefault(const Constant(''))();

  TextColumn get folderName => text().named('folder_name').unique()();

  TextColumn get pdfFilename => text().named('pdf_filename')();

  TextColumn get coverPath => text().named('cover_path').nullable()();

  IntColumn get totalPages =>
      integer().named('total_pages').withDefault(const Constant(0))();

  IntColumn get ocrProgress =>
      integer().named('ocr_progress').withDefault(const Constant(0))();

  IntColumn get aiProgress =>
      integer().named('ai_progress').withDefault(const Constant(0))();

  TextColumn get languageCode =>
      text().named('language_code').withDefault(const Constant('ben'))();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get fileSize =>
      integer().named('file_size').withDefault(const Constant(0))();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
