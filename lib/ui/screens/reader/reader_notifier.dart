import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderNotifier extends StateNotifier<double> {
  ReaderNotifier() : super(16);

  void setFontSize(double value) {
    state = value;
  }
}
