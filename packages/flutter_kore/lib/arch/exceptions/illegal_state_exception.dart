/// Default exception indicating that instances
/// throughout kore app is being used in wrong state
class IllegalStateException implements Exception {
  final String message;

  IllegalStateException({
    required this.message,
  });
}
