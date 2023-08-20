import 'package:sample_navigation/domain/interactors/navigation/components/route.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_navigation/ui/bottom_sheets/test_bottom_sheet.dart';

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
