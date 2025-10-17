import 'package:flutter/services.dart';
import 'package:flutter_kore/flutter_kore.dart';

@singleton
class HapticWrapper extends BaseWrapper<Map<String, dynamic>> {
  void lightImact() {
    HapticFeedback.lightImpact();
  }
}
