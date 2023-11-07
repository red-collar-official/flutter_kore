class Link {
  final String? path;
  final List<String> query;
  final Type? customHandler;

  const Link({
    this.path,
    this.query = const [],
    this.customHandler,
  });
}
