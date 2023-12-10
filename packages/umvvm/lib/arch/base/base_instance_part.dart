import 'package:umvvm/umvvm.dart';

/// Base class for parts
/// Parts are smallest mvvm instances
/// They do not have state or dependencies
/// But they can receive events and contain other parts inside
/// Part also contain reference to parent instance and root parent instance of parts tree
/// You can specify input type for part
/// Parts must be annotated with [instancePart] annotation
/// You also can execute requests and cancel them automatically when part will be disposed
/// with [executeAndCancelOnDispose] method
///
/// Example:
///
/// ```dart
/// @instancePart
/// class TestInteractorPart extends BaseInstancePart<void, PostsInteractor> {
///   void testUpdate() {
///     parentInstance.updateState(parentInstance.state.copyWith(
///       active: false,
///     ));
///   }
/// }
/// ```

abstract class BaseInstancePart<Input, T extends MvvmInstance>
    extends MvvmInstance<Input?> with ApiCaller<Input?> {
  /// Instance that created this part
  late T parentInstance;

  /// Root parent instance for this part
  /// If part contain other parts then root parent instance
  /// will be parent instance of the first part in the tree
  late MvvmInstance? rootParentInstance;

  @override
  void initialize(Input? input) {
    super.initialize(input);

    initialized = true;
  }

  @override
  Future<void> initializeAsync(Input? input) async {
    await super.initializeAsync(input);

    initialized = true;
  }

  /// Base method for lightweight instance initialization
  // coverage:ignore-start
  @override
  void initializeWithoutConnections(Input? input) {
    initialized = true;
  }
  // coverage:ignore-end

  /// Base method for lightweight async instance initialization
  // coverage:ignore-start
  @override
  Future<void> initializeWithoutConnectionsAsync(Input? input) async {
    initialized = true;
  }
  // coverage:ignore-end
}

/// [BaseInstancePart] that applies to every [MvvmInstance] subtype
abstract class UniversalInstancePart<Input>
    extends BaseInstancePart<Input, MvvmInstance> {}
