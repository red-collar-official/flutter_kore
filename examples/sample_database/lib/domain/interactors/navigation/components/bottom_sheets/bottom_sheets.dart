import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_database/ui/bottom_sheets/test_bottom_sheet.dart';

import 'bottom_sheet_names.dart';

class BottomSheets {
  static UIRoute<BottomSheetNames> autharization() {
    return UIRoute<BottomSheetNames>(
      name: BottomSheetNames.autharization,
      child: TestBottomSheet(),
      defaultSettings: const UIBottomSheetRouteSettings(),
    );
  }
}
