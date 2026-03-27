import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryNotifier extends StateNotifier<String> {
  LibraryNotifier() : super('');

  void setQuery(String value) {
    state = value;
  }
}
