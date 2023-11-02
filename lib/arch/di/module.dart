import 'package:umvvm/umvvm.dart';

/// Class describing set of dependencies
/// that need to be initialized if instance depending on this module is created
abstract class InstancesModule {
  /// List of all dependencies required in this module
  List<Connector> get dependencies;

  /// Unique module id
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
