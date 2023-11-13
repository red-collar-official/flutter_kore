import 'dart:async';

import 'package:umvvm/umvvm.dart';

/// Utility class to debounce actions
/// 
/// Example:
/// 
/// ```dart
/// final debouncer = Debouncer(const Duration(milliseconds: 200));
/// 
/// debouncer(() {
///   // do something
/// });
/// ```
class Debouncer {
  /// Delay for this debouncer
  Duration delay;

  Timer? _timer;

  /// Flag indicating that this debouncer is disposed
  /// Debouncer bus can't be used if this flag is true 
  bool _isDisposed = false;

  /// Flag indicating that this debouncer is disposed
  /// Debouncer bus can't be used if this flag is true 
  bool get isDisposed => _isDisposed;

  void Function()? _currentCallback;

  Debouncer(
    this.delay,
  );

  // ignore: always_declare_return_types
  call(void Function() callback) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call debouncer after dispose.',
      );
    }

    _currentCallback = callback;

    _timer?.cancel();

    _timer = Timer(delay, () {
      callback();
    });
  }

  /// Cancel internal timer and sets disposed flag to true
  void dispose() {
    _timer?.cancel();

    _currentCallback = null;

    _isDisposed = true;
  }

  /// Immediately executes debouncer action and resets internal timer
  void processPendingImmediately() {
    _timer?.cancel();

    _currentCallback?.call();
  }
}
