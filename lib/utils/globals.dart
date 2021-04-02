import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class Globals {
  static Uuid uuid = Uuid();
  static const URI_PREFIX = "https://othellogame.page.link";
  static const BASE_LINK = "https://othello-league.netlify.app";
  static const ICON_URL =
      "https://github.com/vishnuagbly/Othello/blob/master/icon.png?raw=true";

  // UI Related finals
  static MediaQueryData? _mediaQueryData;
  static final TextStyle primaryTextStyle = GoogleFonts.montserrat(
    fontSize: Globals.primaryFontSize,
  );
  static final double primaryFontSize = Globals.maxScreenWidth * 0.035;
  static final double secondaryFontSize = Globals.maxScreenWidth * 0.032;
  static final BorderRadius borderRadius =
      BorderRadius.circular((maxScreenWidth * 0.03));
  static final textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: Globals.borderRadius,
      borderSide: BorderSide.none,
    ),
    fillColor: Colors.white24,
    filled: true,
  );

  // UI Related finals

  static setMediaQueryData(BuildContext context) =>
      _mediaQueryData = MediaQuery.of(context);

  static double get screenWidth =>
      _mediaQueryData?.size.width ??
      (window.physicalSize.width / window.devicePixelRatio);

  static double get maxScreenWidth => min(screenWidth, 600);

  static double get screenHeight =>
      _mediaQueryData?.size.height ??
      (window.physicalSize.height / window.devicePixelRatio);
}
