import 'package:umvvm/umvvm.dart';
import 'package:sample_database/ui/bottom_sheets/test_bottom_sheet.dart';

import 'bottom_sheet_names.dart';

class BottomSheets {
  static UIRoute<BottomSheetNames> autharization() {
    return UIRoute<BottomSheetNames>(
      name: BottomSheetNames.autharization,
      child: const TestBottomSheet(),
      defaultSettings: const UIBottomSheetRouteSettings(),
    );
  }
}
