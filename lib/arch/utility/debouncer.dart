import 'dart:async';

/// Utility class to debounce actions
class Debouncer {
  Duration delay;
  Timer? _timer;

  void Function()? _currentCallback;

  Debouncer(
    this.delay,
  );

  // ignore: always_declare_return_types
  call(void Function() callback) {
    _currentCallback = callback;

    _timer?.cancel();

    _timer = Timer(delay, () {
      callback();
    });
  }

  // ignore: always_declare_return_types
  void dispose() {
    _timer?.cancel();

    _currentCallback = null;
  }

  /// Executes callback immediately
  void processPendingImmediately() {
    _timer?.cancel();

    _currentCallback?.call();
  }
}
