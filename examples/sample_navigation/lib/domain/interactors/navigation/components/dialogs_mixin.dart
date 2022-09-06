import 'package:sample_navigation/domain/interactors/navigation/components/dialogs.dart';
import 'package:sample_navigation/ui/dialogs/test_dialog.dart';

import '../navigation_interactor.dart';

mixin DialogsMixin {
  Map<Dialogs, RouteBuilder> dialogs = {
    Dialogs.error: (payload) {
      return TestDialog();
    },
  };
}
