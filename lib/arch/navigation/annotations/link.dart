class Link {
  final List<String>? paths;
  final List<String>? regexes;
  final List<String> query;
  final Type? customHandler;
  final Type? customParamsMapper;

  const Link({
    this.paths,
    this.query = const [],
    this.customHandler,
    this.regexes,
    this.customParamsMapper,
  });
}
