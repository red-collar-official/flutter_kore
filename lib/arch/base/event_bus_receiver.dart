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
  /// List<EventBusSubscriber> subscribe() => [
  ///       on<PostLikedEvent>((event) {
  ///         _onPostLiked(event.id);
  ///       }),
  ///     ];
  /// ```
  List<EventBusSubscriber> subscribe() => [];

  final Map<Type, EventBusSubscriber> _subscribers = {};

  bool _paused = false;
  final _eventsReceivedWhilePaused = [];

  /// Underlying stream subsription for [EventBus] events
  StreamSubscription? _eventsSubscription;

  /// Creates stream subscription for [EventBus] events.
  /// If [subscribe] is empty does nothing
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

  /// Subscribes to event of given type
  /// Adds subscriber to local subscribers collection
  @mustCallSuper
  EventBusSubscriber on<T>(
    EventBusSubscriber<T> processor, {
    bool reactsToPause = false,
    bool firesAfterResume = true,
  }) {
    void dynamicProcessor(event) {
      if (reactsToPause && _paused) {
        if (firesAfterResume) {
          _eventsReceivedWhilePaused.add(event);
        }

        return;
      }

      processor(event as T);
    }

    _subscribers[T] = dynamicProcessor;

    return dynamicProcessor;
  }

  @mustCallSuper
  void pause() {
    _paused = true;
  }

  @mustCallSuper
  void resume({bool sendAllEventsReceivedWhilePause = true}) {
    if (!_paused) {
      return;
    }
    
    _paused = false;

    if (sendAllEventsReceivedWhilePause) {
      for (final element in _eventsReceivedWhilePaused) {
        _subscribers[element.runtimeType]?.call(element);
      }
    }

    _eventsReceivedWhilePaused.clear();
  }
}
