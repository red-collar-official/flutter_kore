import 'package:umvvm/umvvm.dart';
import 'package:sample_database/ui/dialogs/test_dialog.dart';

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
