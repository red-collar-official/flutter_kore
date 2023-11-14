import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

part 'dialogs.navigation.dart';

@dialogs
class Dialogs extends RoutesBase with DialogsGen {
  UIRoute<DialogNames> error() {
    return UIRoute(
      name: DialogNames.error,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }
}
