import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'bottom_sheet_names.dart';

class BottomSheets {
  static UIRoute<BottomSheetNames> stub() {
    return UIRoute<BottomSheetNames>(
      name: BottomSheetNames.stub,
      child: Container(),
      defaultSettings: const UIBottomSheetRouteSettings(),
    );
  }
}
