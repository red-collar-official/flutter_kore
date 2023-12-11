import 'package:umvvm/umvvm.dart';

import 'test_widget.dart';

class TestViewModel extends BaseViewModel<TestWidget, int> {
  @override
  int get initialState => 1;

  @override
  void onLaunch(TestWidget widget) {
    // ignore
  }
}
