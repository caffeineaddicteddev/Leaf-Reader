import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/settings_repository.dart';
import 'database_provider.dart';

class AppSettings {
  const AppSettings({
    required this.aiApiKey,
    required this.geminiModel,
    required this.gemmaModel,
    required this.theme,
    required this.libraryPath,
  });

  final String aiApiKey;
  final String geminiModel;
  final String gemmaModel;
  final String theme;
  final String libraryPath;
}

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
      return SettingsRepository(ref.watch(databaseProvider));
    });

final FutureProvider<AppSettings>
settingsProvider = FutureProvider<AppSettings>((Ref ref) async {
  final SettingsRepository repository = ref.watch(settingsRepositoryProvider);
  return AppSettings(
    aiApiKey: await repository.getValue('ai_api_key') ?? '',
    geminiModel:
        await repository.getValue('gemini_model') ?? 'gemini-2.5-flash',
    gemmaModel: await repository.getValue('gemma_model') ?? 'gemma-3-27b-it',
    theme: await repository.getValue('theme') ?? 'light',
    libraryPath: await repository.getValue('library_path') ?? '',
  );
});
