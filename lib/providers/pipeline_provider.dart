import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/processing_status.dart';

class PipelineNotifier extends StateNotifier<ProcessingStatus> {
  PipelineNotifier() : super(ProcessingStatus.idle());

  Future<void> startPipeline(String bookId) async {
    state = const ProcessingStatus(
      phase: ProcessingPhase.ocr,
      currentPage: 0,
      totalPages: 0,
    );
  }

  void cancelPipeline() {
    state = ProcessingStatus.idle();
  }
}

final StateNotifierProvider<PipelineNotifier, ProcessingStatus>
pipelineProvider = StateNotifierProvider<PipelineNotifier, ProcessingStatus>(
  (Ref ref) => PipelineNotifier(),
);
