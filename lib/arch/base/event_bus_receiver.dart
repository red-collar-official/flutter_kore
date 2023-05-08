import 'dart:async';

import 'package:flutter/material.dart';

import 'event_bus.dart';
import 'store.dart';

/// Base class that subscribe to event bus events
abstract class EventBusReceiver {
  /// [Map] of [EventBus] events and function to be executed for this events
  ///
  /// ```dart
  /// @override
  /// Map<String, EventBusSubscriber> get subscribeTo => {
  ///       Events.eventPostLiked: (payload) {
  ///         _onPostLiked(payload);
  ///       }
  ///     };
  /// ```
  Map<String, EventBusSubscriber> get subscribeTo => {};

  /// Underlying stream subsription for [EventBus] events
  StreamSubscription<BusEventData>? eventsSubscription;

  /// Creates stream subscription for [EventBus] events.
  /// If [subscribeTo] is empty does nothing
  @protected
  void subscribeToEvents() {
    if (subscribeTo.keys.isEmpty) {
      return;
    }

    eventsSubscription = EventBus.instance
        .streamOfCollection(subscribeTo.keys.toList())
        .listen((event) {
      subscribeTo[event.name]?.call(event.payload);
    });
  }

  @mustCallSuper
  void initializeSub() {
    subscribeToEvents();
  }

  /// Closes underlying stream subscription for [EventBus]
  @mustCallSuper
  void disposeSub() {
    eventsSubscription?.cancel();
  }
}
