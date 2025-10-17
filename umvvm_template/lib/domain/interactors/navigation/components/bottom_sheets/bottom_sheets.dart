import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

part 'bottom_sheets.navigation.dart';

@bottomSheets
class BottomSheets extends RoutesBase with BottomSheetsGen {
  UIRoute<BottomSheetNames> authorization() {
    return UIRoute(
      name: BottomSheetNames.authorization,
      defaultSettings: const UIBottomSheetRouteSettings(),
      child: Container(),
    );
  }
}
