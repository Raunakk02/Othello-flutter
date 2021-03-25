import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Globals {
  static Uuid uuid = Uuid();
  static MediaQueryData? _mediaQueryData;
  static set mediaQueryData(MediaQueryData data) => _mediaQueryData = data;
  static double get screenWidth => _mediaQueryData?.size.width ?? 500;
  static double get screenHeight => _mediaQueryData?.size.height ?? 500;
}
