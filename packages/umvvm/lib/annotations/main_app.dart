// coverage:ignore-file

/// Annotate main app class
///  ```dart
///  import '../interactors/interactors.dart';
///
///  part 'global_store.g.dart';
///
///  @mainApp
///  class App extends UMvvmApp with AppGen {
///  }
/// ```
class MainApp {
  /// Type if navigation interactor used in app. 
  /// If navigation component is not used you can ignore this parameter
  final Type? navigationInteractorType;

  const MainApp({
    this.navigationInteractorType,
  });
}
