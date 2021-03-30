import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/screens/game_room.dart';
import 'package:othello/screens/signup_screen.dart';
import 'package:othello/utils/globals.dart';

import 'online_rooms.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      this.user = user;
      Navigator.popUntil(context, ModalRoute.withName('/'));
      await Profile.setProfile(context, user);
    });
    initDynamicLinks();
    super.initState();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (dynamicLink) async {
          print("got link");
          final deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.popUntil(context, ModalRoute.withName('/'));
            Navigator.pushNamed(context, deepLink.path);
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );

    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      drawer: SideDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, GameRoom.offlinePvCRouteName);
              },
              child: Text("vs Computer"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, GameRoom.offlinePvPRouteName);
              },
              child: Text('pass n play'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user == null)
                  Navigator.pushNamed(context, SignUpScreen.routeName);
                else
                  Navigator.pushNamed(context, OnlineRooms.routeName);
              },
              child: Text('Online'),
            ),
          ],
        ),
      ),
    );
  }
}
