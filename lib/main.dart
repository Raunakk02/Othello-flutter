import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:othello/screens/signup_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othello/utils/app_module.dart';
import 'package:othello/utils/globals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('Rooms');
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(ModularApp(module: AppModule(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GoogleSignInProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Othello Game',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.brown,
          floatingActionButtonTheme:
              ThemeData.dark().floatingActionButtonTheme.copyWith(
                    backgroundColor: Colors.brown,
                  ),
        ),
      ).modular(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Globals.mediaQueryData = MediaQuery.of(context);
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (_, AsyncSnapshot<User?> authSnapshot) {
        final provider =
            Provider.of<GoogleSignInProvider>(context, listen: false);
        if (provider.isSigningIn) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.brown,
            ),
          );
        } else if (authSnapshot.hasData) {
          return MainMenu();
        } else {
          return SignUpScreen();
        }
      },
    );
  }
}
