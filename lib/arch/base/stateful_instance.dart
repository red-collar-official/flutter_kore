import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/mvvm_instance.dart';

import 'event_bus.dart';
import 'umvvm_app.dart';
import 'store.dart';

/// Base class for storing test data
/// It contains [Store], subscription to [EventBus] events and cached state
/// Do not forget to call dispose method for instances
mixin StatefulMvvmInstance<State, Input> on MvvmInstance<Input> {
  /// [Store] instance containg [State] object
  late Store<State> _store;

  /// Current [State] object
  ///
  /// ```dart
  /// void _onPostLiked(int id) {
  ///   final posts = (state.posts as SuccessData<List<Post>>).result.toList();
  /// }
  /// ```
  State get state => _store.state;

  /// Stream of values for given [State] mapper
  ///
  /// ```dart
  /// Stream<StatefulData<List<Post>>?> get postsStream => getLocalInstance<PostsInteractor>().updates((state) => state.posts);
  /// ```
  Stream<Value> updates<Value>(Value Function(State state) mapper) =>
      _store.updates(mapper);

  /// Stream of changes (a pair of previous and current values of [State]) for given [State] mapper
  ///
  /// ```dart
  /// Stream<StoreChange<StatefulData<List<Post>>?>> get postsStream => getLocalInstance<PostsInteractor>().changes((state) => state.posts);
  /// ```
  Stream<StoreChange<Value>> changes<Value>(
          Value Function(State state) mapper) =>
      _store.changes(mapper);

  /// Underlying stream subsription for [Store] updates
  StreamSubscription<State>? _storeSaveSubscription;

  /// Model as json to be saved to cache
  ///
  /// ```dart
  /// @singleton
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

  /// Flag indicating that this interactor needs to save state to user defaults
  ///
  /// ```dart
  /// @singleton
  /// class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState> {
  ///   @override
  ///   void onRestore(Map<String, dynamic> savedStateObject) {
  ///     updateState(UserDefaultsState.fromJson(savedStateObject));
  ///   }
  ///
  ///   @override
  ///   bool get isRestores => true;
  /// }
  /// ```
  bool get isRestores => false;

  /// Tries to restore cached state
  /// If cached state is empty does nothing
  /// if cached state is not empty calls [onRestore]
  @protected
  Future<void> restoreCachedStateAsync() async {
    restoreCachedStateSync();
  }

  /// Tries to restore cached state
  /// If cached state is empty does nothing
  /// if cached state is not empty calls [onRestore]
  @protected
  void restoreCachedStateSync() {
    if (!isRestores) {
      return;
    }

    final stateFromCacheJsonString = UMvvmApp.cacheGetDelegate(stateId);

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
  /// @basicInstance
  /// class PostsInteractor extends BaseInteractor<PostsState> {
  ///   Future<void> loadPosts({bool refresh = false}) async {
  ///     updateState(state.copyWith(posts: LoadingData()));
  ///
  ///     final response = await Apis.posts.getPosts().execute();
  ///
  ///     if (response.error == null) {
  ///       updateState(state.copyWith(posts: SuccessData(response.result ?? [])));
  ///     } else {
  ///       updateState(state.copyWith(posts: ErrorData(response.error)));
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

  /// Initializes underlying [Store] for given [State]
  void initializeStatefullInstance(Input input) {
    initializeStore(initialState(input));

    if (syncRestore) {
      restoreCachedStateSync();
    } else {
      restoreCachedStateAsync();
    }
  }

  /// Creates stream subscription for store updates
  /// if [savedStateObject] is not empty listens to state updates and puts it to cache using [UMvvmApp.cachePutDelegate]
  /// If [savedStateObject] is empty does nothing
  void _subscribeToStoreUpdates() {
    if (!isRestores) {
      return;
    }

    _storeSaveSubscription = _store.stream.listen((_) async {
      final stateId = state.runtimeType.toString();
      await UMvvmApp.cachePutDelegate(stateId, json.encode(savedStateObject));
    });
  }

  /// Closes underlying stream subscriptions for [Store] and [EventBus]
  @mustCallSuper
  void disposeStore() {
    _storeSaveSubscription?.cancel();
    _store.dispose();
  }

  /// Stream of all state updates
  Stream<State> get stateStream => _store.stream;

  /// Initial state for this interactor
  State initialState(Input input);

  /// State id for this interactor - 
  /// used as key in cache storage
  String get stateId => state.runtimeType.toString();

  /// Flag indicating that cached state should be awaited
  bool get syncRestore => true;
}
