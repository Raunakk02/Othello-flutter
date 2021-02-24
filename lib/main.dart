import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:othello/utils/globals.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Othello Game',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.brown,
        floatingActionButtonTheme:
            ThemeData.dark().floatingActionButtonTheme.copyWith(
                  backgroundColor: Colors.brown,
                ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Globals.mediaQueryData = MediaQuery.of(context);
    return HomePage();
  }
}
