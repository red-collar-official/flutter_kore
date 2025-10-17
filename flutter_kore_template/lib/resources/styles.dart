// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'colors.dart';

class UIStyles {
  static TextStyle desktop_caption_s({Color color = UIColors.surfaceDark}) =>
      TextStyle(
        fontSize: 16,
        height: 1.25,
        color: color,
        decorationColor: color,
        fontWeight: FontWeight.w400,
        textBaseline: TextBaseline.alphabetic,
      );

  // TODO: place app text styles here
}
