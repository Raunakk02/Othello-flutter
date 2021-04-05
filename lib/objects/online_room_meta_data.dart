class OnlineRoomMetaData {
  OnlineRoomMetaData.newSingle(String uid)
      : this.players = [uid],
        this.timestamp = DateTime.now(),
        this.status = null,
        this.id = null;

  OnlineRoomMetaData.fromMap(Map<String, dynamic> map, this.id)
      : this.players = map['players']?.cast<String>()?.toList() ?? [],
        this.timestamp = map['timestamp']?.toDate() ?? DateTime.now(),
        this.status = map['status'];

  final String? id;
  final List<String> players;
  final DateTime timestamp;
  final String? status;

  Map<String, dynamic> toMap() => {
        'players': players,
        'timestamp': timestamp,
        'status': status,
      };
}
