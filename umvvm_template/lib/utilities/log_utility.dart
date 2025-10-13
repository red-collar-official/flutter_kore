// ignore_for_file: avoid_print
// coverage:ignore-file

import 'package:umvvm_template/domain/global/global.dart';

class LogUtility {
  static void e(dynamic e, dynamic trace) async {
    if (!currentFlavor.enableLogs) {
      return;
    }

    print('found error: $e');
    print(trace);
  }

  static void printMessage(dynamic message) async {
    if (!currentFlavor.enableLogs) {
      return;
    }

    printWrapped(message.toString());
  }

  static void printWrapped(String text) => RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
}
