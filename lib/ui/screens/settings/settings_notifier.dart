import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsNotifier extends StateNotifier<bool> {
  SettingsNotifier() : super(false);

  void toggleThemePreview() {
    state = !state;
  }
}
