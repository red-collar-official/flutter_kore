import 'package:flutter/services.dart';
import 'package:umvvm/umvvm.dart';

@singleton
class HapticWrapper extends BaseWrapper<Map<String, dynamic>> {
  void lightImact() {
    HapticFeedback.lightImpact();
  }
}
