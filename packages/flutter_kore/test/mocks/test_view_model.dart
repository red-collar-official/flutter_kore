import 'package:flutter_kore/flutter_kore.dart';

import 'test_widget.dart';

class TestViewModel extends BaseViewModel<TestWidget, int> {
  @override
  int get initialState => 1;

  @override
  void onLaunch() {
    // ignore
  }
}
