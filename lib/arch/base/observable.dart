import 'dart:async';

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
  late StreamController<T> _controller;
  T? _current;
  T? _previous;

  Observable() {
    _controller = StreamController<T>.broadcast(sync: true);
  }

  Observable.initial(T initial) {
    _controller = StreamController<T>.broadcast(sync: true);

    update(initial);
  }

  /// Current value of observable object
  T? get current => _current;

  /// Previous value of observable object
  T? get previous => _previous;

  /// Broadcast stream of [current] changes
  Stream<T> get stream => _controller.stream.asBroadcastStream();

  /// Updates [current] and [previous]
  void update(T data) {
    _previous = current;
    _current = data;

    _controller.add(data);
  }

  /// Closes underlaying stream controller
  void dispose() {
    _controller.close();
  }
}
