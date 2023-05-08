import 'dependent_element.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
///  ```dart
/// @defaultInteractor
/// class TestInteractor extends BaseInteractor<int> {
///   @override
///   int initialState(Map<String, dynamic>? input) => 1;
/// }
/// ```
abstract class BaseInteractor<State>
    extends BaseDependentElement<State, Map<String, dynamic>?> {
}
