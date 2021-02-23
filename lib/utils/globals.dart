import 'package:flutter/material.dart';

class Globals {
  static MediaQueryData _mediaQueryData;
  static set mediaQueryData(MediaQueryData data) => _mediaQueryData = data;
  static double get screenWidth => _mediaQueryData?.size?.width ?? 500;

}