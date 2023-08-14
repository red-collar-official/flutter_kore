import 'package:mvvm_redux/mvvm_redux.dart';

@singletonService
class StringService extends DefaultService<String> {
  @override
  String provideInstance(Map<String, dynamic>? params) {
    return '';
  }
}
