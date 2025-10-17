import 'dart:async';
import 'package:flutter/services.dart';

class DeviceLocale {
  static const MethodChannel _channel = MethodChannel(
    'com.flutter_kore_template.plugins/device_locale',
  );

  /// Gets native prefered languages in format '[xx_YY, zz_WW]'
  static Future<List?> preferredLanguages() =>
      _channel.invokeMethod('preferredLanguages');

  /// Gets native device locale in format 'xx_YY'
  static Future<String?> currentLocale() =>
      _channel.invokeMethod('currentLocale');

  /// Gets native device country code in format 'XX'
  static Future<String?> currentCountry() =>
      _channel.invokeMethod('currentCountry');
}
