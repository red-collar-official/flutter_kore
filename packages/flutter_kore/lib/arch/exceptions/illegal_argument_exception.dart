/// Default exception indicating that instances
/// throughout kore app is being used with wrong arguments
class IllegalArgumentException implements Exception {
  final String message;

  IllegalArgumentException({
    required this.message,
  });
}
