import 'package:flutter_modular/flutter_modular.dart';
import 'package:othello/main.dart';
import 'package:othello/screens/game_room.dart';
import 'package:othello/screens/otp_screen.dart';
import 'package:othello/screens/phone_input_screen.dart';
import 'package:othello/screens/signup_screen.dart';

class AppModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => MainPage()),
    ChildRoute(SignUpScreen.routeName, child: (_, __) => SignUpScreen()),
    ChildRoute(PhoneInputScreen.routeName,
        child: (_, __) => PhoneInputScreen()),
    ChildRoute(OtpScreen.routeName, child: (_, __) => OtpScreen()),
    ChildRoute(GameRoom.offlinePvCRouteName,
        child: (_, __) => GameRoom.offlinePvC()),
    ChildRoute(GameRoom.offlinePvPRouteName,
        child: (_, __) => GameRoom.offlinePvP()),
  ];
}
