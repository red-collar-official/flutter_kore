import 'package:umvvm/umvvm.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
///  ```dart
/// @basicInstance
/// class TestInteractor extends BaseInteractor<int, String> {
///   @override
///   int initialState(String? input) => 1;
/// }
/// ```
abstract class BaseInteractor<State, Input> extends MvvmInstance<Input?>
    with StatefulMvvmInstance<State, Input?>, DependentMvvmInstance<Input?> {
  @override
  void initialize(Input? input) {
    super.initialize(input);

    initializeStore(initialState(input));

    initializeDependencies(input);

    restoreCachedState();

    initialized = true;
  }

  @override
  void dispose() {
    super.dispose();

    disposeStore();
    disposeDependencies();

    initialized = false;
  }

  @override
  Future<void> initializeAsync(Input? input) async {
    if (initialized) {
      return;
    }

    await super.initializeAsync(input);

    initialize(input);

    await initializeDependenciesAsync(input);
  }
}
