/// Annotate classes as default interactor
/// Alternative would be singleton interactor
/// You also can specify type of input data fot this interactor
///  ```dart
/// @DefaultInteractor(inputType: String)
/// class TestInteractor extends BaseInteractor<int, String> {
///   @override
///   int get initialState => 1;
/// }
/// ```
class DefaultInteractor {
  /// Input type for this interactor, Map<String, dynamic> by default
  final Type inputType;

  const DefaultInteractor({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate classes as default interactor
/// Alternative would be singleton interactor
///  ```dart
/// @defaultInteractor
/// class TestInteractor extends BaseInteractor<int, Map<String, dynamic>> {
///   @override
///   int get initialState => 1;
/// }
/// ```
const defaultInteractor = DefaultInteractor();
