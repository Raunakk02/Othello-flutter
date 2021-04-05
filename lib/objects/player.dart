import 'savable.dart';
import 'package:othello/utils/globals.dart';
import 'room_data.dart';

class Player extends Savable {
  final String id;
  final String? nextMoveFnId;

  Player({String? id, this.nextMoveFnId}) : this.id = id ?? Globals.uuid.v1();

  Player.fromMap(Map map)
      : this.id = map['playerId'] ?? Globals.uuid.v1(),
        this.nextMoveFnId = map['nextMoveFnId'];

  Map<String, dynamic> toMap() => {
        "playerId": id,
        "nextMoveFnId": nextMoveFnId,
      };

  Future<List<int>?> nextTurn(RoomData roomData) {
    if (nextMoveFnId == null) return Future.value(null);
    if (!NextMoveFns.fns.containsKey(nextMoveFnId)) return Future.value(null);
    return NextMoveFns.fns[nextMoveFnId]!(roomData, id);
  }
}
