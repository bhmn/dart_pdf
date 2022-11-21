library mywidgets;

import 'package:flutter/material.dart';

Widget generalText(String text,
    {String fontFamily = 'VazirRegular',
    double fontSize = 18,
    Color color = Colors.black}) {
  return Text(
    text,
    style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: color),
  );
}
