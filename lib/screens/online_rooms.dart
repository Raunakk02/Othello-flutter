import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/custom_pop_up_menu.dart';
import 'package:othello/components/future_dialog.dart';
import 'package:othello/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/objects/online_room_meta_data.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/utils/globals.dart';
import 'package:othello/utils/networks.dart';

class OnlineRooms extends StatelessWidget {
  static const routeName = '/online_rooms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("All Rooms"),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => FutureDialog<void>(
                          future: Networks.createNewRoom(context),
                          hasData: (_) =>
                              CommonAlertDialog("Successfully Created Room"),
                        ));
              },
            )
          ],
        ),
        drawer: SideDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: StreamBuilder<List<OnlineRoomMetaData>>(
            stream: Networks.getRoomMetaData(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              final data = snapshot.data;

              return data != null && data.length != 0
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
                    );
            },
          ),
        ));
  }
}

class RoomCard extends StatelessWidget {
  RoomCard(
    this.data, {
    Key? key,
  }) : super(key: key);

  final OnlineRoomMetaData data;
  final _popupKey = GlobalKey<CustomPopupState>();
  final _key = LabeledGlobalKey('room_card');

  CustomPopup customPopup(BuildContext context) => CustomPopup(
        key: _popupKey,
        child: InkWell(
          onTap: () async {
            _popupKey.currentState!.remove();
            if (data.id != null)
              await showDialog(
                context: context,
                builder: (context) => FutureDialog<void>(
                  future: Networks.deleteRoom(data.id!),
                  hasData: (_) =>
                      CommonAlertDialog("Successfully deleted room"),
                ),
              );
          },
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            decoration: BoxDecoration(
              color: Color(0xFF333333),
              borderRadius: BorderRadius.circular(Globals.maxScreenWidth * 0.1),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(
                color: Colors.red,
                fontSize: Globals.maxScreenWidth * 0.035,
              ),
            ),
          ),
        ),
        showBarrierColor: true,
        parentKey: _key,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          customPopup(context).show(context);
        },
        child: Container(
          child: Center(
            child: Container(
              key: _key,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: Globals.borderRadius,
              ),
              width: Globals.maxScreenWidth * 0.9,
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  DefaultTextStyle(
                    style: GoogleFonts.montserrat(
                      fontSize: Globals.secondaryFontSize,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    child: FutureBuilder<List<Profile>>(
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
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('dd-MM-yyyy').format(data.timestamp),
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
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
