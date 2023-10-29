import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'dialog_names.dart';

class Dialogs {
  static UIRoute<DialogNames> stub() {
    return UIRoute<DialogNames>(
      name: DialogNames.stub,
      child: Container(),
      defaultSettings: const UIDialogRouteSettings(),
    );
  }
}
