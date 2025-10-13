import 'dart:async';

import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/main_base.dart';

Future<void> main() async {
  await runAppWithFlavor(Flavor.stage);
}
