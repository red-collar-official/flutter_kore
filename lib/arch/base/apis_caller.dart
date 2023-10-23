import 'package:umvvm/umvvm.dart';

mixin ApiCaller<Input> on MvvmInstance<Input> {
  final List<BaseRequest> requests = [];

  Future<Response<T>> executeRequest<T>(BaseRequest<T> request) async {
    requests.add(request);

    final result = await request.execute();

    requests.remove(request);

    return result;
  }

  void cancelAllRequests() {
    for (final element in requests) {
      element.cancel();
    }
  }
}
