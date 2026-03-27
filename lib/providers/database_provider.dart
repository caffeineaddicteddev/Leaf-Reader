import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';

final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
