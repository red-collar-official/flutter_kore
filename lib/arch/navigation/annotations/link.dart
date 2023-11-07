/// Annotation describing link parameters for given route
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
  /// If regexes specified must be null
  final List<String>? paths;

  /// List of regexes supported by this route
  /// If paths specified must be null
  final List<String>? regexes;

  /// Query params for this link
  /// Supported in the next formats
  /// 'name' - required query param
  /// 'name?' - conditional query param
  /// 'name=test' - required query with given value
  /// 'name=test|test2' - required query that matches one of given values
  /// 'name=[test1, test2]' - required query param with list of values
  final List<String> query;

  /// Custom handler for this route
  final Type? customHandler;

  /// Custom mapper for this route
  /// Must be specified if [regexes] is not null
  final Type? customParamsMapper;

  const Link({
    this.paths,
    this.query = const [],
    this.customHandler,
    this.regexes,
    this.customParamsMapper,
  });
}
