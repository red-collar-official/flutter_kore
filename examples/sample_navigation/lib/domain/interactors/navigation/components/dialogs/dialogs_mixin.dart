import 'package:sample_navigation/domain/interactors/interactors.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialogs.dart';
import 'package:sample_navigation/ui/dialogs/test_dialog.dart';

mixin DialogsMixin {
  Map<Dialogs, RouteBuilder> dialogs = {
    Dialogs.error: (payload) {
      return TestDialog();
    },
  };
}
