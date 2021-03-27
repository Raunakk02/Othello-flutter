import 'package:flutter/material.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/screens/game_room.dart';

class MainMenu extends StatelessWidget {
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
          ],
        ),
      ),
    );
  }
}
