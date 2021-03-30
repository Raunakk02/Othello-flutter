import 'package:flutter_modular/flutter_modular.dart';
import 'package:othello/screens/enter_room.dart';
import 'package:othello/screens/enter_name.dart';
import 'package:othello/screens/game_room.dart';
import 'package:othello/screens/main_menu.dart';
import 'package:othello/screens/online_rooms.dart';
import 'package:othello/screens/phone_input_screen.dart';
import 'package:othello/screens/signup_screen.dart';

class AppModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => MainMenu()),
    ChildRoute(SignUpScreen.routeName, child: (_, __) => SignUpScreen()),
    ChildRoute(PhoneInputScreen.routeName,
        child: (_, __) => PhoneInputScreen()),
    ChildRoute(GameRoom.offlinePvCRouteName,
        child: (_, __) => GameRoom.offlinePvC()),
    ChildRoute(GameRoom.offlinePvPRouteName,
        child: (_, __) => GameRoom.offlinePvP()),
    ChildRoute(OnlineRooms.routeName, child: (_, __) => OnlineRooms()),
    ChildRoute(EnterName.routeName, child: (_, __) => EnterName()),
    ChildRoute(OnlineRooms.routeName + '/:id',
        child: (_, args) => EnterRoom(args.params['id'])),
  ];
}
