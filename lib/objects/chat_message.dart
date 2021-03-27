import 'savable.dart';

class ChatMessage extends Savable {
  ChatMessage({
    required this.msg,
    required this.uid,
    required this.timestamp,
  });

  static List<ChatMessage> fromMaps(List<Map> maps) =>
      List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));

  ChatMessage.fromMap(Map map)
      : this.msg = map['msg'],
        this.uid = map['uid'],
        this.timestamp = map['timestamp']?.toDate();

  final String msg;
  final String uid;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
    'msg': msg,
    'uid': uid,
    'timestamp': timestamp,
  };
}
