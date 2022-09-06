import 'package:sample_navigation/ui/bottom_sheets/test_bottom_sheet.dart';

import '../navigation_interactor.dart';
import 'bottom_sheets.dart';

mixin BottomSheetsMixin {
  Map<BottomSheets, RouteBuilder> bottomSheets = {
    BottomSheets.autharization: (payload) {
      return TestBottomSheet();
    },
  };
}
