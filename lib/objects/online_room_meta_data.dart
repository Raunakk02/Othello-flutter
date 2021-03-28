class OnlineRoomMetaData {
  OnlineRoomMetaData.newSingle(String uid)
      : this.players = [uid],
        this.timestamp = DateTime.now(),
        this.status = null;

  OnlineRoomMetaData.fromMap(Map<String, dynamic> map)
      : this.players = map['players']?.cast<String>()?.toList(),
        this.timestamp = map['timestamp']?.toDate(),
        this.status = map['status'];

  final List<String> players;
  final DateTime timestamp;
  final String? status;

  Map<String, dynamic> toMap() => {
    'players': players,
    'timestamp': timestamp,
    'status': status,
  };
}
