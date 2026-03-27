import 'dart:async';

class JsonMutex {
  Future<void> _tail = Future<void>.value();

  Future<T> protect<T>(Future<T> Function() action) {
    final Future<void> previous = _tail;
    final Completer<void> completer = Completer<void>();
    _tail = completer.future;
    return previous.then((_) => action()).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }
}
