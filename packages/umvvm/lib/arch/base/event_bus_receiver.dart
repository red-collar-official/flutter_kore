import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef EventBusSubscriber<T> = void Function(T event);

/// Mixin that subscribe to event bus events
mixin EventBusReceiver {
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

  bool isPaused = false;
  final _eventsReceivedWhilePaused = [];

  /// Underlying stream subsription for [EventBus] events
  StreamSubscription? _eventsSubscription;

  final _testReceivedEventsController = StreamController();

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
    _testReceivedEventsController.close();

    _receivedEvents.clear();
    _eventsReceivedWhilePaused.clear();
  }

  /// Subscribes to event of given type
  ///
  /// Adds subscriber to local subscribers collection
  ///
  /// [processor] - function that handles event
  /// [reactsToPause] - flag indicating that this handler is paused when assosiated view is paused
  /// [firesAfterResume] - flag indicating that events that are received while pause need to be replayed
  @mustCallSuper
  EventBusSubscriber on<T>(
    EventBusSubscriber<T> processor, {
    bool reactsToPause = false,
    bool firesAfterResume = true,
  }) {
    void dynamicProcessor(event) {
      if (UMvvmApp.isInTestMode) {
        _receivedEvents.add(event.runtimeType);

        _testReceivedEventsController.add(event);
      }

      if (reactsToPause && isPaused) {
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

  /// Sets paused flag to false so events stop processing
  @mustCallSuper
  void pauseEventBusSubscription() {
    isPaused = true;
  }

  /// Resumes events processing
  ///
  /// [sendAllEventsReceivedWhilePause] - flag indicating that events received while pause will be resent
  @mustCallSuper
  void resumeEventBusSubscription({
    bool sendAllEventsReceivedWhilePause = true,
  }) {
    if (!isPaused) {
      return;
    }

    isPaused = false;

    if (sendAllEventsReceivedWhilePause) {
      for (final element in _eventsReceivedWhilePaused) {
        _subscribers[element.runtimeType]?.call(element);
      }
    }

    _eventsReceivedWhilePaused.clear();
  }

  /// Returns true if underlying events list contains given event name
  ///
  /// [event] - event type to check
  /// [count] - optional count of events that must have been received
  @visibleForTesting
  bool checkEventWasReceived(Type event, {int? count}) {
    if (count == null) {
      return _receivedEvents.contains(event);
    }

    return _receivedEvents.whereType<Type>().length == count;
  }

  /// Waits till given event is received by this instance
  ///
  /// [event] - event type to check
  /// [count] - optional count of events that must have been received
  /// [timeout] - maximum duration to wait for events
  @visibleForTesting
  Future<void> waitTillEventIsReceived(
    Type event, {
    int? count,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    await for (final _ in _testReceivedEventsController.stream
        .timeout(timeout, onTimeout: (s) => s.close())) {
      if (checkEventWasReceived(event, count: count)) {
        break;
      }
    }
  }

  /// Cleans collection of received events
  ///
  /// Useful for testing when you need to check event processing
  @visibleForTesting
  void cleanupReceivedEvents() {
    _receivedEvents.clear();
  }
}
