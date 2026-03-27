import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Future<String?> getValue(String key) async {
    final Setting? row =
        await (select(settings)
              ..where(($SettingsTable table) => table.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(
      settings,
    ).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }

  Stream<String?> watchValue(String key) {
    return (select(settings)
          ..where(($SettingsTable table) => table.key.equals(key)))
        .watchSingleOrNull()
        .map((Setting? row) => row?.value);
  }
}
