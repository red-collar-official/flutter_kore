import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/ui/dialogs/test_dialog.dart';

import 'dialog_names.dart';

class Dialogs {
  static UIRoute<DialogNames> error() {
    return UIRoute<DialogNames>(
      name: DialogNames.error,
      child: TestDialog(),
      defaultSettings: const UIDialogRouteSettings(),
    );
  }
}
