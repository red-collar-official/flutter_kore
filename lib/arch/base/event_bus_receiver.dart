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
  List<EventBusSubscriber> subscribe() => [];

  final Map<Type, EventBusSubscriber> _subscribers = {};

  /// Underlying stream subsription for [EventBus] events
  StreamSubscription? _eventsSubscription;

  /// Creates stream subscription for [EventBus] events.
  /// If [subscribeTo] is empty does nothing
  @protected
  void _subscribeToEvents() {
    subscribe();

    if (_subscribers.isEmpty) {
      return;
    }

    _eventsSubscription = EventBus.instance
        .streamOfCollection(_subscribers.keys.toList())
        .listen((event) {
      _subscribers[event.runtimeType]?.call(event);
    });
  }

  @mustCallSuper
  void initializeSub() {
    _subscribeToEvents();
  }

  /// Closes underlying stream subscription for [EventBus]
  @mustCallSuper
  void disposeSub() {
    _eventsSubscription?.cancel();
  }

  EventBusSubscriber on<T>(EventBusSubscriber<T> processor) {
    void dynamicProcessor(event) {
      processor(event as T);
    }

    _subscribers[T] = dynamicProcessor;

    return dynamicProcessor;
  }
}
