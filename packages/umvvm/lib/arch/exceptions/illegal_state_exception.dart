/// Default exception indicating that instances
/// throughout mvvm app is being used in wrong state
class IllegalStateException implements Exception {
  final String message;

  IllegalStateException({
    required this.message,
  });
}
