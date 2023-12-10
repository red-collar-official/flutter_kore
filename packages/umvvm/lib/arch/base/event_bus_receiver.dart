import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef EventBusSubscriber<T> = void Function(T event);

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
  final List<Type> _receivedEvents = [];

  bool paused = false;
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
      if (reactsToPause && paused) {
        if (firesAfterResume) {
          _eventsReceivedWhilePaused.add(event);

          if (UMvvmApp.isInTestMode) {
            _receivedEvents.add(event.runtimeType);
          }
        }

        return;
      }

      if (UMvvmApp.isInTestMode) {
        _receivedEvents.add(event.runtimeType);
      }

      processor(event as T);
    }

    _subscribers[T] = dynamicProcessor;

    return dynamicProcessor;
  }

  /// Sets paused flag to false so events stop processing
  @mustCallSuper
  void pauseEventBusSubscription() {
    paused = true;
  }

  /// Resumes events processing
  @mustCallSuper
  void resumeEventBusSubscription({
    bool sendAllEventsReceivedWhilePause = true,
  }) {
    if (!paused) {
      return;
    }

    paused = false;

    if (sendAllEventsReceivedWhilePause) {
      for (final element in _eventsReceivedWhilePaused) {
        _subscribers[element.runtimeType]?.call(element);
      }
    }

    _eventsReceivedWhilePaused.clear();
  }

  /// Returns true if underlying events list contains given event name
  @visibleForTesting
  bool checkEventWasReceived(Type event) {
    return _receivedEvents.contains(event);
  }
}
