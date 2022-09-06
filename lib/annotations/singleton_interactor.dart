class SingletonInteractorAnnotation {
  const SingletonInteractorAnnotation();
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
const singletonInteractor = SingletonInteractorAnnotation();
