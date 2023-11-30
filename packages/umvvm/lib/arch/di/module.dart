import 'package:umvvm/umvvm.dart';

/// Class describing set of dependencies
/// that need to be initialized if instance depending on this module is created
/// 
/// Example:
/// 
/// ```dart
/// class TestModule extends InstancesModule {
///   @override
///   List<Connector> get dependencies => [
///         app.connectors.postInteractorConnector(),
///         app.connectors.postsInteractorConnector(),
///       ];
/// 
///   @override
///   String get id => 'test';
/// }
/// 
/// class Modules {
///   static final test = TestModule();
/// }
/// 
/// @singleton
/// class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
///   @override
///   String provideInstance(Map<String, dynamic>? input) {
///     return '';
///   }
/// 
///   @override
///   List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
///     Modules.test,
///   ];
/// }
/// ```
abstract class InstancesModule {
  // coverage:ignore-start

  /// List of all dependencies required in this module
  List<Connector> get dependencies => [];

  /// List of all parts required in this module
  List<PartConnector> get parts => [];

  // coverage:ignore-end

  /// Unique module id - this will be basically id of scope in DI container
  String get id;

  /// Returns list of connectors for this module for eventual dependent instance
  List<Connector> scopedDependencies() {
    return dependencies.map((element) {
      if (element.scope != BaseScopes.weak) {
        return element;
      } else {
        return element.copyWithScope(id);
      }
    }).toList();
  }
}
