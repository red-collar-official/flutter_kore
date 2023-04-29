import 'package:mvvm_redux/mvvm_redux.dart';

@singletonService
class StringService extends BaseService<String> {
  @override
  String provideInstance(Map<String, dynamic>? params) {
    return '';
  }
}
