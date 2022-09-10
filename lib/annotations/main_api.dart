class MainApiAnnotation {
  const MainApiAnnotation();
}

/// Annotate class as main Api holder
/// 
/// ```dart
/// part 'apis.g.dart';
/// 
/// @mainApi
/// class Apis with ApisGen {}
/// ```
const mainApi = MainApiAnnotation();