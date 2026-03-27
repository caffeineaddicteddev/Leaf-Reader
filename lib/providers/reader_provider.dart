import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/clean_page.dart';

final cleanPagesProvider = StreamProvider.family<List<CleanPage>, String>(
  (Ref ref, String bookId) => const Stream<List<CleanPage>>.empty(),
);

final StateProvider<Map<String, double>> readerProgressProvider =
    StateProvider<Map<String, double>>((Ref ref) => <String, double>{});
