import 'package:flutter/material.dart';

class DelayUtility {
  static Future<void> pause({int millis = 50}) async {
    await Future.delayed(Duration(milliseconds: millis));
  }

  static void withDelay(VoidCallback action, {int millis = 50}) async {
    await Future.delayed(Duration(milliseconds: millis), action);
  }
}
