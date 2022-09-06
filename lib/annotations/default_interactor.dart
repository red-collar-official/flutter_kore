class DefaultInteractorAnnotation {
  const DefaultInteractorAnnotation();
}

/// Annotate classes as default interactor
/// Alternative would be singleton interactor
///  ```dart
/// @defaultInteractor
/// class TestInteractor extends BaseInteractor<int> {
///   @override
///   int get initialState => 1;
/// }
/// ```
const defaultInteractor = DefaultInteractorAnnotation();