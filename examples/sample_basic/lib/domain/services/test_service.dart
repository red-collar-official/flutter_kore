import 'package:umvvm/mvvm_redux.dart';

@singletonService
class StringService extends BaseService<String, Map<String, dynamic>?> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}
