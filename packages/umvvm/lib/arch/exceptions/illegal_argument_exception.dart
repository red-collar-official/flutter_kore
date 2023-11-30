/// Default exception indicating that instances 
/// throughout mvvm app is being used with wrong arguments
class IllegalArgumentException implements Exception {
  final String message;

  IllegalArgumentException({
    required this.message,
  });
}
