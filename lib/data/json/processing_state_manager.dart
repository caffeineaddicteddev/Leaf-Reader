import 'dart:convert';
import 'dart:io';

import '../../domain/models/processing_continuation_state.dart';
import 'json_mutex.dart';

class ProcessingStateManager {
  ProcessingStateManager({JsonMutex? mutex}) : _mutex = mutex ?? JsonMutex();

  final JsonMutex _mutex;

  Future<void> initialize({
    required String filePath,
    required String bookId,
  }) async {
    await _mutex.protect(() async {
      final File file = File(filePath);
      if (await file.exists()) {
        return;
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(ProcessingContinuationState.initial(bookId).toJson()),
      );
    });
  }

  Future<ProcessingContinuationState> read(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      return ProcessingContinuationState.initial('');
    }
    final String content = await file.readAsString();
    if (content.trim().isEmpty) {
      return ProcessingContinuationState.initial('');
    }
    final Map<String, Object?> json =
        (jsonDecode(content) as Map<Object?, Object?>).cast<String, Object?>();
    return ProcessingContinuationState.fromJson(json);
  }

  Future<void> write({
    required String filePath,
    required ProcessingContinuationState state,
  }) async {
    await _mutex.protect(() async {
      final File file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(state.toJson()));
    });
  }

  Future<void> update({
    required String filePath,
    required ProcessingContinuationState Function(
      ProcessingContinuationState current,
    )
    transform,
  }) async {
    await _mutex.protect(() async {
      final ProcessingContinuationState current = await read(filePath);
      final File file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(transform(current).toJson()));
    });
  }

  Future<void> clear(String filePath) async {
    await _mutex.protect(() async {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    });
  }
}
