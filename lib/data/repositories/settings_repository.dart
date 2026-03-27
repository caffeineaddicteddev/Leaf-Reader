import '../database/app_database.dart';

class SettingsRepository {
  const SettingsRepository(this._database);

  final AppDatabase _database;

  Future<String?> getValue(String key) => _database.settingsDao.getValue(key);

  Future<void> setValue(String key, String value) =>
      _database.settingsDao.setValue(key, value);

  Stream<String?> watchValue(String key) =>
      _database.settingsDao.watchValue(key);
}
