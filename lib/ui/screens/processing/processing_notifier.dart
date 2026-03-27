import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/processing_status.dart';

class ProcessingNotifier extends StateNotifier<ProcessingStatus> {
  ProcessingNotifier() : super(ProcessingStatus.idle());
}
