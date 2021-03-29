import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:othello/objects/savable.dart';
import 'package:othello/screens/enter_name.dart';
import 'package:othello/utils/networks.dart';

class Profile extends Savable {
  Profile(String name, this.id) : this._name = name;

  static Profile? __globalProfile;

  Profile.fromUser(User user)
      : assert(user.displayName != null),
        this._name = user.displayName!,
        this.id = user.uid,
        this._photoURL = user.photoURL;

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

  ///Call inside FirebaseAuth user changes listen method
  static Future<void> setProfile(BuildContext context, User? user) async {
    if (user != null) {
      if (user.displayName == null) {
        String? name =
            await Navigator.pushNamed<String>(context, EnterName.routeName);
        if (name == null) throw "Name is null";
        await user.updateProfile(displayName: name);
      }
      __globalProfile = Profile.fromUser(user);
    } else
      __globalProfile = null;
    if (__globalProfile != null) Networks.createProfile(__globalProfile!);
  }

  static Profile? get global => __globalProfile;

  @override
  Map<String, dynamic> toMap() => {
        'name': _name,
        'id': id,
        'photoURL': _photoURL,
        'totalScore': _totalScore,
      };
}
