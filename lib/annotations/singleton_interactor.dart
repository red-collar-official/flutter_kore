/// Annotate classes as singleton interactor
/// Alternative would be default interactor
///  ```dart
/// @SingletonInteractor(inputType: String)
/// class TestInteractor extends BaseInteractor<int, String> {
///   @override
///   int get initialState => 1;
/// }
/// ```
class SingletonInteractor {
  /// Input type for this interactor, Map<String, dynamic> by default
  final Type inputType;

  const SingletonInteractor({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate classes as singleton interactor
/// Alternative would be default interactor
///  ```dart
/// @singletonInteractor
/// class TestInteractor extends BaseInteractor<int, Map<String, dynamic>> {
///   @override
///   int get initialState => 1;
/// }
/// ```
const singletonInteractor = SingletonInteractor();
