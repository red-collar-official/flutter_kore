import 'package:mvvm_redux/mvvm_redux.dart';

@singletonService
class StringService extends BaseService<String> {
  @override
  String createService(Map<String, dynamic>? params) {
    return '';
  }
}
