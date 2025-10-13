import 'dart:async';

import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/ui/app/app_view.dart';
import 'package:umvvm_template/utilities/utilities.dart';
import 'package:flutter/material.dart';

Future<void> runAppWithFlavor(Flavor flavor) async {
  await runZonedGuarded<Future<void>>(
    () async {
      await initApp(flavor: flavor);

      runApp(AppView(
        key: AppView.globalKey,
      ));
    },
    LogUtility.e,
  );
}

Future<void> runAppWithFlavorWithoutZone(
  Flavor flavor, {
  bool initializeFirebase = true,
}) async {
  await initApp(flavor: flavor);

  runApp(AppView(
    key: AppView.globalKey,
  ));
}
