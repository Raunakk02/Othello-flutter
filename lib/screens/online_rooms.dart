import 'dart:math';

import 'package:intl/intl.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/future_dialog.dart';
import 'package:othello/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/loading_screen.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/objects/online_room_meta_data.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/utils/globals.dart';
import 'package:othello/utils/networks.dart';

class OnlineRooms extends StatelessWidget {
  static const routeName = '/online_rooms';

  @override
  Widget build(BuildContext context) {
    return LoadingScreen<List<OnlineRoomMetaData>>(
        future: Networks.getRoomMetaData(context),
        func: (data) {
          return DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'montserrat',
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text("All Rooms"),
                actions: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => FutureDialog<void>(
                                future: Networks.createNewRoom(context),
                                hasData: (_) => CommonAlertDialog(
                                    "Successfully Created Room"),
                              ));
                    },
                  )
                ],
              ),
              drawer: SideDrawer(),
              body: data != null && data.length != 0
                  ? ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        return RoomCard(data[i]);
                      },
                    )
                  : Center(
                    child: Text(
                        "No Rooms Currently Available",
                      ),
                  ),
            ),
          );
        });
  }
}

class RoomCard extends StatelessWidget {
  const RoomCard(
    this.data, {
    Key? key,
  }) : super(key: key);

  final OnlineRoomMetaData data;

  @override
  Widget build(BuildContext context) {
    double borderRadius = max(Globals.screenWidth, 700) * 0.1;
    return Card(
      elevation: 2,
      color: Colors.white24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: Globals.screenWidth * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            FutureBuilder<List<Profile>>(
              future: getProfiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator();
                final profiles = snapshot.data;
                if (profiles == null) return Text("No one in this room");
                if (profiles.length < 2)
                  return Text("You are the only one in this room");
                return Text(
                    "${profiles[0].name.capitalize()} vs ${profiles[1].name.capitalize()}");
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat.yMd().format(data.timestamp),
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<Profile>> getProfiles() async {
    List<Profile> profiles = [];
    for (var id in data.players) {
      final profile = await Networks.getProfile(id);
      if (profile != null) profiles.add(profile);
    }
    return profiles;
  }
}
