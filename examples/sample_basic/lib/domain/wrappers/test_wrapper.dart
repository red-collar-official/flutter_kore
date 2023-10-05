import 'package:umvvm/umvvm.dart';

@singleton
class StringWrapper extends BaseWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}
