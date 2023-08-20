import 'dart:async';

import 'package:flutter/foundation.dart';

/// Basic Event bus implementation
/// You can [send] events and [streamOf] to stream of event callbacks or collection of events callbacks with [streamOfCollection]
///
///  ```dart
/// void example() {
///   final subscription = EventBus.instance.listenToCollection(['initialized', 'disposed']).listen((event) {
///     // do something with events
///   });
///
///  EventBus.instance.send(BusEventData('initialized', {
///     'currentTime': DateTime.now()
///   }));
///
///   subscription.cancel();
/// }
/// ```
class EventBus {
  late final StreamController _streamController;
  final _events = [];

  EventBus._internal() {
    _streamController = StreamController.broadcast();
  }

  static final EventBus _singletonEventBus = EventBus._internal();

  static EventBus get instance {
    return _singletonEventBus;
  }

  /// Creates separate instance of event bus
  /// Usefull when you need eventbus specificaly for one task, for example file upload
  // ignore: prefer_constructors_over_static_methods
  static EventBus newSeparateInstance() {
    return EventBus._internal();
  }

  /// Return dart stream of events with particular name
  Stream<T> streamOf<T>() {
    return _streamController.stream.where((event) => event is T).map((event) => event as T);
  }

  /// Return dart stream of events with particular names
  Stream streamOfCollection(List<Type> events) {
    return _streamController.stream
        .where((event) => events.contains(event.runtimeType));
  }

  /// Sends event to stream controller
  void send(dynamic event) {
    if (kDebugMode) {
      _events.add(event);
    }

    _streamController.add(event);
  }

  /// Closes underlying stream controller
  void close() {
    _streamController.close();
  }

  /// Returns true if underlying events list contains given event name
  @visibleForTesting
  bool checkEventWasSent(Type event) {
    return _events.contains(event);
  }
}
