import 'package:flutter/material.dart';

class SpaceBox extends SizedBox {
  const SpaceBox({Key? key, double width = 8, double height = 8})
      : super(key: key, width: width, height: height);

  // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
  SpaceBox.width([double value = 8]) : super(width: value);

  // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
  SpaceBox.height([double value = 8]) : super(height: value);
}
