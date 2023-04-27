import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'event_bus.dart';
import 'event_bus_receiver.dart';
import 'mvvm_redux_app.dart';
import 'store.dart';

/// Base class for storing test data
/// It contains [Store], subscription to [EventBus] events and cached state
/// Do not forget to call dispose method for instances
abstract class MvvmElement<State> extends EventBusReceiver {
  /// [Store] instance containg [State] object
  late Store<State> _store;

  /// Current [State] object
  ///
  /// ```dart
  /// void _onPostLiked(int id) {
  ///   final posts = (state.posts as ResultData<List<Post>>).result.toList();
  /// }
  /// ```
  State get state => _store.state;

  /// Stream of values for given [State] mapper
  ///
  /// ```dart
  /// Stream<StatefulData<List<Post>>?> get postsStream => interactors.get<PostsInteractor>().updates((state) => state.posts);
  /// ```
  Stream<Value> updates<Value>(Value Function(State state) mapper) =>
      _store.updates(mapper);

  /// Stream of changes (a pair of previous and current values of [State]) for given [State] mapper
  ///
  /// ```dart
  /// Stream<StoreChange<StatefulData<List<Post>>?>> get postsStream => interactors.get<PostsInteractor>().changes((state) => state.posts);
  /// ```
  Stream<StoreChange<Value>> changes<Value>(
          Value Function(State state) mapper) =>
      _store.changes(mapper);

  /// Underlying stream subsription for [Store] updates
  StreamSubscription<State>? _storeSaveSubscription;

  /// Model as json to be saved to cache
  ///
  /// ```dart
  /// @singletonInteractor
  /// class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState> {
  ///   @override
  ///   void onRestore(Map<String, dynamic> savedStateObject) {
  ///     updateState(UserDefaultsState.fromJson(savedStateObject));
  ///   }
  ///
  ///   @override
  ///   Map<String, dynamic> get savedStateObject => state.toJson();
  /// }
  /// ```
  Map<String, dynamic> get savedStateObject => {};

  /// Tries to restore cached state
  /// If cached state is empty does nothing
  /// if cached state is not empty calls [onRestore]
  @protected
  void restoreCachedState() {
    final stateId = state.runtimeType.toString();
    final stateFromCacheJsonString = MvvmReduxApp.cacheGetDelegate(stateId);

    if (stateFromCacheJsonString.isEmpty) {
      return;
    }

    final restoredMap = json.decode(stateFromCacheJsonString);
    onRestore(restoredMap);
  }

  /// Callback to get cache object
  /// Use it to call [updateState] and restore saved state object
  void onRestore(Map<String, dynamic> savedStateObject) {}

  /// Updates state in underlying [Store]
  ///
  /// ```dart
  /// @defaultInteractor
  /// class PostsInteractor extends BaseInteractor<PostsState> {
  ///   Future<void> loadPosts({bool refresh = false}) async {
  ///     updateState(state.copyWith(posts: StatefulData.loading()));
  ///
  ///     final response = await Apis.posts.getPosts().execute();
  ///
  ///     if (response.error == null) {
  ///       updateState(state.copyWith(posts: StatefulData.result(response.result ?? [])));
  ///     } else {
  ///       updateState(state.copyWith(posts: StatefulData.error(response.error)));
  ///     }
  ///   }
  /// }
  /// ```
  void updateState(State state) {
    _store.updateState(state);
  }

  /// Initializes underlying [Store] for given [State]
  void initializeStore(State initialState) {
    _store = Store<State>();
    _store.initialize(initialState);

    _subscribeToStoreUpdates();
  }

  /// Creates stream subscription for store updates
  /// if [savedStateObject] is not empty listens to state updates and puts it to cache using [MvvmReduxApp.cachePutDelegate]
  /// If [savedStateObject] is empty does nothing
  void _subscribeToStoreUpdates() {
    if (savedStateObject.keys.isEmpty) {
      return;
    }

    _storeSaveSubscription = _store.stream.listen((_) async {
      final stateId = state.runtimeType.toString();
      await MvvmReduxApp.cachePutDelegate(
          stateId, json.encode(savedStateObject));
    });
  }

  /// Closes underlying stream subscriptions for [Store] and [EventBus]
  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    _storeSaveSubscription?.cancel();
    _store.dispose();
  }
}
