import 'dart:collection';

import 'package:othello/objects/room_data.dart';
import 'package:othello/objects/savable.dart';
import 'package:othello/utils/globals.dart';

class MoveData extends Savable {
  MoveData({
    required this.board,
    required this.duration,
    required this.playerIdTurn,
    required this.timestamp,
  }) : this.id = Globals.uuid.v1();

  MoveData.fromMap(Map map, int width, int height)
      : this.board =
            fromFlatList(map['board'].cast<int>().toList(), width, height),
        this.duration = Duration(seconds: map['duration']),
        this.playerIdTurn = map['playerIdTurn'],
        this.timestamp = map['timestamp'],
        this.id = Globals.uuid.v1();

  static List<MoveData> fromMaps(List<Map> maps, int width, int height) =>
      List.generate(
          maps.length, (i) => MoveData.fromMap(maps[i], width, height));

  final UnmodifiableListView<UnmodifiableListView<int>> board;
  final String id;
  final Duration duration;
  final DateTime timestamp;
  final String playerIdTurn;

  Map<String, dynamic> toMap() => {
        'board': board.flat,
        'duration': duration.inSeconds,
        'playerIdTurn': playerIdTurn,
        'timestamp': timestamp,
      };
}

extension moveDataExtension on List<MoveData> {
  List<String> print() {
    List<String> res = [];
    for (var move in this) res.add(move.id);
    return res;
  }
}

extension on List<int> {
  String toFilteredString() {
    String res = "(";
    for (int i = 0; i < this.length; i++) {
      if (this[i] == -1) continue;
      res += '${this[i]}, ';
    }
    res += ")";
    return res;
  }
}
