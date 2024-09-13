import 'dart:async';

import 'package:umvvm/umvvm.dart';

typedef StateUpdater<State> = void Function(State state);
typedef StoreMapper<Value, State> = Value Function(State state);

/// Class to hold store change
class StoreChange<Value> {
  final Value? previous;
  final Value next;

  StoreChange(
    this.previous,
    this.next,
  );
}

/// Store is providing access to [State] for current containing class and [EventBus]
class Store<State> {
  /// Observable for [State] that belongs to this store
  late Observable<State> _state;

  /// Flag indicating that this store is disposed
  /// Store can't be used if this flag is true
  bool _isDisposed = false;

  /// Current state in store
  State get state => _state.current!;

  /// Flag indicating that this store is disposed
  ///
  /// Store can't be used if this flag is true
  bool get isDisposed => _isDisposed;

  /// Main stream for all store values
  Stream<State> get stream => _state.stream.map((event) => event.next!);

  /// Updates current state
  ///
  /// [state] - new state value
  ///
  /// Listeners of [stream] will be notified about changes
  ///
  /// ```dart
  /// Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
  ///   updateState(state.copyWith(posts: LoadingData()));
  ///
  ///   late Response<List<Post>> response;
  ///
  ///   if (refresh) {
  ///     response = await Apis.posts.getPosts(0, limit).execute();
  ///   } else {
  ///     response = await Apis.posts.getPosts(offset, limit).execute();
  ///   }
  ///
  ///   if (response.isSuccessful || response.isSuccessfulFromDatabase) {
  ///     updateState(state.copyWith(posts: SuccessData(response.result ?? [])));
  ///   } else {
  ///     updateState(state.copyWith(posts: ErrorData(response.error)));
  ///   }
  /// }
  /// ```
  void updateState(State update) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call updateState after dispose.',
      );
    }

    _state.update(update);
  }

  /// Initializes internal state [Observable]
  ///
  /// [state] - initial state value
  void initialize(State state) {
    _state = Observable<State>.initial(state);
  }

  /// Disposes internal state [Observable]
  void dispose() {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call dispose if store is already disposed.',
      );
    }

    _state.dispose();

    _isDisposed = true;
  }

  /// Stream of new values in [state]
  ///
  /// Using mapper you can select values you want to listen
  ///
  /// ```dart
  /// Stream<StatefulData<List<Post>>?> get postsStream => getLocalInstance<PostsInteractor>().updates((state) => state.posts);
  /// ```
  Stream<Value> updates<Value>(StoreMapper<Value, State> mapper) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call updates after dispose.',
      );
    }

    return _state.stream.where((element) {
      return mapper(element.previous ?? element.next!) !=
          mapper(element.next as State);
    }).map((event) => mapper(event.next as State));
  }

  /// Stream of changes of values [state]
  ///
  /// Using mapper you can select values you want to listen
  /// In contrast to [updates] this stream returns pairs of values -
  /// new state and previous state, so you can easily compare them if needed
  ///
  /// ```dart
  /// Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => getLocalInstance<PostsInteractor>().changes((state) => state.posts);
  /// ```
  Stream<StoreChange<Value>> changes<Value>(StoreMapper<Value, State> mapper) {
    if (_isDisposed) {
      throw IllegalStateException(
        message: 'Can\'t call changes after dispose.',
      );
    }

    return _state.stream.map((event) => StoreChange(
          mapper(event.previous ?? event.next!),
          mapper(event.next as State),
        ));
  }
}
