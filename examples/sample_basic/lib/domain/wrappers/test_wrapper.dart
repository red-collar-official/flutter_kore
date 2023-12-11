import 'package:umvvm/umvvm.dart';

@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance() {
    return '';
  }
}
