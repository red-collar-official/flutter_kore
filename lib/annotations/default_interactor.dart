class DefaultInteractor {
  final Type inputType;

  const DefaultInteractor({
    this.inputType = Map<String, dynamic>,
  });
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
const defaultInteractor = DefaultInteractor();
