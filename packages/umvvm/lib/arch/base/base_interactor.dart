import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
/// Interactors can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when interactor will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
///
/// Example:
///
/// ```dart
/// @basicInstance
/// class TestInteractor extends BaseInteractor<int, String> {
///   @override
///   int get initialState => 1;
/// }
/// ```
abstract class BaseInteractor<State, Input> extends MvvmInstance<Input?>
    with
        StatefulMvvmInstance<State, Input?>,
        DependentMvvmInstance<Input?>,
        ApiCaller<Input?> {
  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    initializeDependencies();
    initializeStatefullInstance();
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeStore();
    disposeDependencies();
    cancelAllRequests();
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();
    await initializeDependenciesAsync();
  }

  @mustCallSuper
  @override
  void initializeWithoutConnections(Input? input) {
    super.initializeWithoutConnections(input);

    initializeStore();
  }
}
