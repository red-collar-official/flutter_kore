import 'package:umvvm/umvvm.dart';

/// Base class for parts
/// Parts are smallest mvvm instances
/// They do not have state or dependencies
/// But they can receive events and contain other parts inside
/// Part also contain reference to parent instance and root parent instance of parts tree
/// You can specify input type for part
/// Parts must be annotated with [instancePart] annotation
/// You also can execute requests and cancel them automatically when part will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
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

abstract class BaseInstancePart<Input, T extends MvvmInstance> extends MvvmInstance<Input?> with ApiCaller<Input?> {
  /// Instance that created this part
  late T parentInstance;

  /// Root parent instance for this part
  ///
  /// If part contain other parts then root parent instance
  /// will be parent instance of the first part in the tree
  MvvmInstance? rootParentInstance;
}

/// [BaseInstancePart] that applies to every [MvvmInstance] subtype
abstract class UniversalInstancePart<Input> extends BaseInstancePart<Input, MvvmInstance> {}

/// [BaseInstancePart] that applies to given [MvvmInstance] subtype
abstract class RestrictedInstancePart<Input, T extends MvvmInstance> extends BaseInstancePart<Input, T> {}
