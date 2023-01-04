import 'dart:async';

import 'package:flutter/foundation.dart';

/// Class to hold name and payload for [EventBus] event
class BusEventData {
  final String name;
  final dynamic payload;

  BusEventData(this.name, this.payload);
}

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
  late final StreamController<BusEventData> _streamController;
  final _events = <String>[];

  EventBus._internal() {
    _streamController = StreamController.broadcast();
  }

  static final EventBus _singletonEventBus = EventBus._internal();

  static EventBus get instance {
    return _singletonEventBus;
  }

  /// Return dart stream of events with particular name
  Stream<BusEventData> streamOf(String eventName) {
    return _streamController.stream.where((event) => event.name == eventName);
  }

  /// Return dart stream of events with particular names
  Stream<BusEventData> streamOfCollection(List<String> eventNames) {
    return _streamController.stream
        .where((event) => eventNames.contains(event.name));
  }

  /// Sends event to stream controller
  void send(String eventName, {dynamic payload}) {
    final event = BusEventData(eventName, payload);

    if (kDebugMode) {
      _events.add(event.name);
    }

    _streamController.add(event);
  }

  /// Closes underlying stream controller
  void close() {
    _streamController.close();
  }

  /// Returns true if underlying events list contains given event name
  @visibleForTesting
  bool checkEventWasSent(String eventName) {
    return _events.contains(eventName);
  }
}
