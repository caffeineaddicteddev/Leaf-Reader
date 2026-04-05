import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/books_dao.dart';
import 'daos/settings_dao.dart';
import 'tables/books_table.dart';
import 'tables/processing_queue_table.dart';
import 'tables/settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[Books, Settings, ProcessingQueue],
  daos: <Type>[BooksDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await batch((Batch batch) {
        batch.insertAll(settings, <SettingsCompanion>[
          SettingsCompanion.insert(key: 'ai_api_key', value: ''),
          SettingsCompanion.insert(
            key: 'gemini_model',
            value: 'gemini-3-flash-preview',
          ),
          SettingsCompanion.insert(key: 'gemma_model', value: 'gemma-3-27b-it'),
          SettingsCompanion.insert(key: 'ai_mode', value: 'false'),
          SettingsCompanion.insert(key: 'vision_api_key', value: ''),
          SettingsCompanion.insert(key: 'theme', value: 'system'),
          SettingsCompanion.insert(key: 'library_path', value: ''),
        ]);
      });
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.addColumn(books, books.lastReadPage);
      }
      if (from < 3) {
        await migrator.addColumn(books, books.lastScrollOffset);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final File databaseFile = File(
      p.join(documentsDirectory.path, 'leaf.sqlite'),
    );
    return NativeDatabase(databaseFile);
  });
}
