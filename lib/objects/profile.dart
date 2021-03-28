import 'package:othello/objects/savable.dart';

class Profile extends Savable {
  Profile(String name, this.id): this._name = name;

  Profile.fromMap(Map<String, dynamic> map)
      : assert(map['name'] == null),
        assert(map['id'] == null),
        this._name = map['name'],
        this.id = map['id'],
        this._photoURL = map['photoURL'],
        this._totalScore = map['totalScore'];

  String _name;
  final String id;
  String? _photoURL;
  double? _totalScore;

  String get name => _name;

  @override
  Map<String, dynamic> toMap() => {
        'name': _name,
        'id': id,
        'photoURL': _photoURL,
        'totalScore': _totalScore,
      };
}
