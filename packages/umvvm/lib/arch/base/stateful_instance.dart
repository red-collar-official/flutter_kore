import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/mvvm_instance.dart';

import 'event_bus.dart';
import 'umvvm_app.dart';
import 'store.dart';

/// Wrapper class for state updates for [StateFulInstanceSettings]
/// 
/// Exposes [Stream] for needed value and also current value of mapped state value
class StateStream<T> {
  /// Stream for given state value
  final Stream<T?> stream;

  /// Mapper for state
  final T Function() mapper;

  /// Returns current mapped state value
  T? get current => mapper();

  const StateStream(
    this.stream,
    this.mapper,
  );
}

/// Settings for stateful instance. Contain state restore flags and state id
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
///   Map<String, dynamic> get savedStateObject => state.toMap();
///
///   @override
///   StateFulInstanceSettings get stateFulInstanceSettings =>
///      StateFulInstanceSettings(
///        stateId: state.runtimeType.toString(),
///      );
/// }
/// ```
class StateFulInstanceSettings {
  StateFulInstanceSettings({
    this.isRestores = false,
    required this.stateId,
    this.syncRestore = true,
  });

  /// Flag indicating that this instance needs to save state to user defaults
  final bool isRestores;

  /// State id for this instance -
  /// used as key in cache storage
  final String stateId;

  /// Flag indicating that cached state should be awaited
  final bool syncRestore;
}

/// Base class for storing test data
///
/// It contains [Store], subscription to [EventBus] events and cached state
/// Do not forget to call dispose method for instances
///
/// If used you need to call [initializeStatefulInstance] in [MvvmInstance.initialize] call
/// And call [disposeStore] in [MvvmInstance.dispose] call
///
/// ```dart
/// abstract class BaseBox<State> extends MvvmInstance<dynamic> with StatefulMvvmInstance<State, dynamic> {
///   String get boxName;
///
///   late final hiveWrapper = app.instances.get<HiveWrapper>();
///
///   @mustCallSuper
///   @override
///   void initialize(Input? input) {
///     super.initialize(input);
///
///     initializeStatefulInstance(input);
///
///     initialized = true;
///   }
///
///   @mustCallSuper
///   @override
///   void dispose() {
///     super.dispose();
///
///     disposeStore();
///
///     initialized = false;
///   }
/// }
/// ```
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

  /// [StateStream] object for given mapper for instance state
  ///
  /// ```dart
  /// late final posts = postsInteractor.wrapUpdates((state) => state.posts);
  /// ```
  StateStream<Value> wrapUpdates<Value>(Value Function(State) mapper) {
    return StateStream(updates(mapper), () => mapper(state));
  }

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

  /// Tries to restore cached state
  ///
  /// If cached state is empty does nothing
  /// if cached state is not empty calls [onRestore]
  @protected
  Future<void> restoreCachedStateAsync() async {
    restoreCachedStateSync();
  }

  /// Tries to restore cached state
  ///
  /// If cached state is empty does nothing
  /// if cached state is not empty calls [onRestore]
  @protected
  void restoreCachedStateSync() {
    if (!stateFulInstanceSettings.isRestores) {
      return;
    }

    final stateFromCacheJsonString = UMvvmApp.cacheGetDelegate(
      stateFulInstanceSettings.stateId,
    );

    if (stateFromCacheJsonString == null || stateFromCacheJsonString.isEmpty) {
      return;
    }

    final restoredMap = json.decode(stateFromCacheJsonString);
    onRestore(restoredMap);
  }

  /// Callback to get cache object
  ///
  /// Use it to call [updateState] and restore saved state object
  ///
  /// [savedStateObject] - restored state value
  void onRestore(Map<String, dynamic> savedStateObject) {}

  /// Updates state in underlying [Store]
  ///
  /// [state] - new state value
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
  void initializeStore() {
    _store = Store<State>();
    _store.initialize(initialState);

    _subscribeToStoreUpdates();
  }

  /// Initializes underlying [Store] for given [State]
  void initializeStatefulInstance() {
    initializeStore();

    if (stateFulInstanceSettings.syncRestore) {
      restoreCachedStateSync();
    } else {
      restoreCachedStateAsync();
    }
  }

  /// Creates stream subscription for store updates
  ///
  /// if [savedStateObject] is not empty listens to state updates and puts it to cache using [UMvvmApp.cachePutDelegate]
  /// If [savedStateObject] is empty does nothing
  void _subscribeToStoreUpdates() {
    if (!stateFulInstanceSettings.isRestores) {
      return;
    }

    _storeSaveSubscription = _store.stream.listen((_) async {
      final stateId = stateFulInstanceSettings.stateId;
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

  /// Initial state for this instance
  State get initialState;

  /// Flag indicating that cached state should be awaited
  StateFulInstanceSettings get stateFulInstanceSettings =>
      StateFulInstanceSettings(
        stateId: state.runtimeType.toString(),
      );
}
