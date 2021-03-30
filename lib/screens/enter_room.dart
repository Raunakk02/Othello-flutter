import 'package:flutter/material.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/loading_screen.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/utils/networks.dart';

import 'game_room.dart';

class EnterRoom extends StatelessWidget {
  EnterRoom(this.roomId);

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return LoadingScreen<RoomData>(
        future: Networks.enterRoom(roomId),
        func: (roomData) {
          if (roomData == null)
            return CommonAlertDialog("Room does not exist", error: true);
          return GameRoom(roomData);
        });
  }
}
