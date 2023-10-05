import '../di/dependent_element.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
///  ```dart
/// @basicInstance
/// class TestInteractor extends BaseInteractor<int, String> {
///   @override
///   int initialState(String? input) => 1;
/// }
/// ```
abstract class BaseInteractor<State, Input>
    extends BaseDependentElement<State, Input?> {}
