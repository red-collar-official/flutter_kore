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
  final Type? navigationInteractorType;

  const MainApp({
    this.navigationInteractorType,
  });
}
