import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/screens/game_room.dart';
import 'package:othello/screens/signup_screen.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
