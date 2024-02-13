/// Annotation describing link parameters for given route
///
/// Example:
///
/// ```dart
/// @Link(
///   paths: ['posts/:{id}'],
///   query: [
///     'filter',
///   ],
/// )
/// ```
class Link {
  /// List of paths supported by this route
  /// 
  /// If regexes specified must be null
  final List<String>? paths;

  /// List of regexes supported by this route
  /// 
  /// If paths specified must be null
  final List<String>? regexes;

  /// Query params for this link
  /// 
  /// Supported in the next formats
  /// 
  /// 'name' - required query param
  /// 'name=test' - required query with given value
  /// 'name=test|test2' - required query that matches one of given values
  /// 'name=[test1, test2]' - required query param with list of values
  final List<String> query;

  /// Query params for every link in [paths] array.
  /// 
  /// Supported in the next formats
  /// 
  /// 'name' - required query param
  /// 'name=test' - required query with given value
  /// 'name=test|test2' - required query that matches one of given values
  /// 'name=[test1, test2]' - required query param with list of values
  final List<List<String>>? queriesForPath;

  /// Custom handler for this route
  final Type? customHandler;

  /// Custom mapper for this route
  /// 
  /// Must be specified if [regexes] is not null
  final Type? customParamsMapper;

  /// List of fragments supported by this link
  final List<String>? possibleFragments;

  /// List of fragments supported by every link in [paths] array
  final List<List<String>>? possibleFragmentsForPath;

  const Link({
    this.paths,
    this.query = const [],
    this.customHandler,
    this.regexes,
    this.customParamsMapper,
    this.possibleFragments,
    this.queriesForPath,
    this.possibleFragmentsForPath,
  });
}
