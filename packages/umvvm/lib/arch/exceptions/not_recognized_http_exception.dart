/// Default exception indicating that http request 
/// failed with unknown error
class NotRecognizedHttpException implements Exception {
  final String message;

  NotRecognizedHttpException({
    required this.message,
  });
}
