class MainAppAnnotation {
  const MainAppAnnotation();
}

/// Annotate main app class
///  ```dart
///  import '../interactors/interactors.dart';
///
///  part 'global_store.g.dart';
///
///  @mainApp
///  class App extends MvvmReduxApp with AppGen {
///  }
/// ```
const mainApp = MainAppAnnotation();
