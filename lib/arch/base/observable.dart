import 'dart:async';

class ObservableChange<T> {
  final T? next;
  final T? previous;

  ObservableChange(
    this.next,
    this.previous,
  );
}

/// Base class for observable object
///
/// You can get [stream] of object changes and also [update] object data
///
/// Example:
/// ```dart
/// void example() {
///   final userName = Observable<String>.initial("Ted");
///
///   final subscription = userName.stream.listen((name) {
///     // do something with name
///   });
///
///   userName.update('John');
///
///   print('current userName=${userName.current}');
///
///   subscription.cancel();
///   userName.dispose();
/// }
/// ```
class Observable<T> {
  late StreamController<ObservableChange<T>> _controller;
  T? _current;

  Observable() {
    _controller = StreamController<ObservableChange<T>>.broadcast();
  }

  Observable.initial(T initial) {
    _controller = StreamController<ObservableChange<T>>.broadcast();

    update(initial);
  }

  /// Current value of observable object
  T? get current => _current;

  /// Broadcast stream of [current] changes
  Stream<ObservableChange<T>> get stream =>
      _controller.stream.asBroadcastStream();

  /// Updates [current] and [previous]
  void update(T data) {
    final change = ObservableChange(data, _current);
    _current = data;

    if (!_controller.isClosed) {
      _controller.add(change);
    }
  }

  /// Closes underlaying stream controller
  void dispose() {
    _controller.close();
  }
}
