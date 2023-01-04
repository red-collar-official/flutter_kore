import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BackgroundTransformer extends DefaultTransformer {
  BackgroundTransformer() : super(jsonDecodeCallback: _parseJson);
}

// ignore: always_declare_return_types
_parseAndDecode(String response) {
  return jsonDecode(response);
}

// ignore: always_declare_return_types
_parseJson(String text) {
  return compute(_parseAndDecode, text);
}
