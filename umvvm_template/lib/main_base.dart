import 'dart:async';

import 'package:flutter_kore_template/domain/global/global.dart';
import 'package:flutter_kore_template/ui/app/app_view.dart';
import 'package:flutter_kore_template/utilities/utilities.dart';
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
