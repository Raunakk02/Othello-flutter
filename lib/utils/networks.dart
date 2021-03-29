import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:othello/objects/online_room_meta_data.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:provider/provider.dart';

abstract class Networks {
  static final _firestore = FirebaseFirestore.instance;
  static final _rooms = _firestore.collection('rooms');
  static final _profiles = _firestore.collection('profiles');
  static final _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  ///Rooms MetaData
  static Stream<List<OnlineRoomMetaData>> getRoomMetaData(
      BuildContext context) {
    final user = _getUser(context);
    final snapshots =
        _rooms.where('players', arrayContains: user.uid).snapshots();
    final stream = snapshots.map<List<OnlineRoomMetaData>>((elem) {
      List<OnlineRoomMetaData> res = [];
      for (var snapshot in elem.docs) {
        final data = snapshot.data();
        if (data != null)
          res.add(OnlineRoomMetaData.fromMap(data, snapshot.id));
      }
      return res;
    });
    return stream;
  }

  static Future<void> createNewRoom(BuildContext context) async {
    final user = _getUser(context);
    await _rooms.add(OnlineRoomMetaData.newSingle(user.uid).toMap());
  }

  static Future<void> deleteRoom(String roomId) async {
    final callable = _functions.httpsCallable('deleteRoom');
    await callable(roomId);
  }

  /// Profiles
  static Future<Profile?> getProfile(String uid) async {
    final data = (await _profiles.doc(uid).get()).data();
    if (data == null) return null;
    return Profile.fromMap(data);
  }

  static Future<void> createProfile(Profile profile) async {
    await _profiles.doc(profile.id).set(profile.toMap());
  }

  /// Utils
  static _getUser(BuildContext context) {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    final user = provider.auth.currentUser;
    if (user == null) throw "User not logged in";
    return user;
  }
}
