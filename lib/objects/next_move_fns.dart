import 'package:othello/objects/profile.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/utils/networks.dart';

abstract class NextMoveFns {
  static String offlineTempId = 'offlineTemp';
  static String onlineId = 'onlineId';
  static Map<String, Future<List<int>?> Function(RoomData, String)> fns = {
    offlineTempId: (roomData, id) async {
      await Future.delayed(Duration(seconds: 0));
      return roomData.getPossibleMovesList().first;
    },
    onlineId: _onlineNextMoveFn,
  };

  static Future<List<int>?> _onlineNextMoveFn(
      RoomData roomData, String id) async {
    if (Profile.global == null) throw 'not authenticated';
    if (id == Profile.global!.id) return null;

    final stream = Networks.roomStream(roomData.id);
    await for (var snapshot in stream) {
      if (!snapshot.exists) throw 'room got deleted';

      final data = snapshot.data()!;

      List<List<int>> currentBoard = fromFlatList(
          data[RoomDataLabels.currentBoard]?.cast<int>()?.toList() ??
              RoomData.initializeBoard(roomData.length, roomData.height).flat,
          roomData.length,
          roomData.height);
      final move = _getMove(roomData.currentBoard, currentBoard);
      if (move == null) continue;
      return move;
    }
  }

  static List<int>? _getMove(
      List<List<int>> lastMove, List<List<int>> currentMove) {
    int totalLastPieces = 0;
    int totalCurrentPieces = 0;
    for (int i = 0; i < lastMove.length; i++) {
      for (int j = 0; j < lastMove[i].length; j++) {
        if (lastMove[i][j] == -1 && currentMove[i][j] != -1) return [i, j];
        if (lastMove[i][j] != -1) totalLastPieces++;
        if (currentMove[i][j] != -1) totalCurrentPieces++;
      }
    }
    if (totalCurrentPieces < totalLastPieces) throw 'undo is not supported yet';
  }
}
