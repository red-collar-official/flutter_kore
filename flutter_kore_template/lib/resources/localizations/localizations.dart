import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_kore_template/l10n/app_localizations.dart';
import 'package:flutter_kore_template/utilities/utilities.dart';

class AppLocalization {
  AppLocalization._internal();

  static final AppLocalization _singletonAppLocalization =
      AppLocalization._internal();

  late AppLocalizations localizations;
  String? localeCode;

  static AppLocalization getInstance() {
    return _singletonAppLocalization;
  }

  Future<void> load({String? localeCode}) async {
    this.localeCode = localeCode;

    try {
      localizations = await AppLocalizations.delegate.load(Locale(localeCode!));
    } catch (e) {
      LogUtility.printMessage(
        'Didn`t find $localeCode localization file, using default en locale',
      );

      localizations = await AppLocalizations.delegate.load(const Locale('en'));
    }
  }
}
