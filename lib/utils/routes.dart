import 'package:flutter/cupertino.dart';
import 'package:othello/main.dart';
import 'package:othello/screens/otp_screen.dart';
import 'package:othello/screens/phone_input_screen.dart';
import 'package:othello/screens/signup_screen.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  '/': (_) => MainPage(),
  SignUpScreen.routeName: (_) => SignUpScreen(),
  PhoneInputScreen.routeName: (_) => PhoneInputScreen(),
  OtpScreen.routeName: (_) => OtpScreen(),
};
