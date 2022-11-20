library mywidgets;

import 'package:flutter/material.dart';

Widget generalText(String text,
    {double fontSize = 18, Color color = Colors.black}) {
  return Text(
    text,
    style: TextStyle(fontFamily: 'VazirBold', fontSize: fontSize, color: color),
  );
}
