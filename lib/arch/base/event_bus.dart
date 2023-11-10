import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

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
  /// Underlying controller fot this event bus
  late final StreamController _streamController;

  /// Collection of events sent through event bus 
  /// only used in test mode
  final _events = [];

  /// Flag indicating that this event bus is disposed
  /// Event bus can't be used if this flag is true 
  bool _isDisposed = false;

  /// Flag indicating that this event bus is disposed
  /// Event bus can't be used if this flag is true 
  bool get isDisposed => _isDisposed;

  EventBus._internal() {
    _streamController = StreamController.broadcast();
  }

  static final EventBus _singletonEventBus = EventBus._internal();

  static EventBus get instance {
    return _singletonEventBus;
  }

  /// Creates separate instance of event bus
  /// Useful when you need eventbus specificaly for one task, for example file upload
  // ignore: prefer_constructors_over_static_methods
  static EventBus newSeparateInstance() {
    return EventBus._internal();
  }

  /// Return dart stream of events with particular name
  Stream<T> streamOf<T>() {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call streamOf after dispose.',
      );
    }

    return _streamController.stream
        .where((event) => event is T)
        .map((event) => event as T);
  }

  /// Return dart stream of events with particular names
  Stream streamOfCollection(List<Type> events) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call streamOfCollection after dispose.',
      );
    }

    return _streamController.stream
        .where((event) => events.contains(event.runtimeType));
  }

  /// Sends event to stream controller
  void send(dynamic event) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call send after dispose.',
      );
    }

    if (UMvvmApp.isInTestMode) {
      _events.add(event);
    }

    _streamController.add(event);
  }

  /// Closes underlying stream controller
  void dispose() {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call dispose if event bus is already disposed.',
      );
    }

    _streamController.close();

    _isDisposed = true;
  }

  /// Returns true if underlying events list contains given event name
  @visibleForTesting
  bool checkEventWasSent(Type event) {
    return _events.indexWhere((element) => element.runtimeType == event) != -1;
  }
}
