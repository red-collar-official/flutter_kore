import 'package:sample/domain/interactors/navigation/components/dialogs.dart';
import 'package:sample/ui/dialogs/test_dialog.dart';

import '../navigation_interactor.dart';

mixin DialogsMixin {
  Map<Dialogs, RouteBuilder> dialogs = {
    Dialogs.error: (payload) {
      return TestDialog();
    },
  };
}
