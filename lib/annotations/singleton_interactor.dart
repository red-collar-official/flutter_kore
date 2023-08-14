class SingletonInteractor {
  final Type inputType;

  const SingletonInteractor({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate classes as singleton interactor
/// Alternative would be default interactor
///  ```dart
/// @singletonInteractor
/// class TestInteractor extends BaseInteractor<int> {
///   @override
///   int get initialState => 1;
/// }
/// ```
const singletonInteractor = SingletonInteractor();
