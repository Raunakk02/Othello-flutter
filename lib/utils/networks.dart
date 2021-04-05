import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:othello/objects/online_room_meta_data.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:provider/provider.dart';

abstract class Networks {
  static final _firestore = FirebaseFirestore.instance;
  static final _rooms = _firestore.collection('rooms');
  static final _profiles = _firestore.collection('profiles');
  static final _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');
  static const _roomDataPath = "/roomData/data";
  static const _lastMovesPath = "/lastMoves";

  ///Rooms MetaData
  static Stream<List<OnlineRoomMetaData>> getRoomsMetaData(
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

  static Future<OnlineRoomMetaData> getRoomMetaData(String roomId) async {
    final snapshot = await _rooms.doc(roomId).get();
    if (!snapshot.exists) throw "Room does not exist";
    late final OnlineRoomMetaData room;
    try {
      room = OnlineRoomMetaData.fromMap(snapshot.data()!, snapshot.id);
    } catch (error) {
      print(error);
      throw "Corrupted Room Meta Data";
    }
    return room;
  }

  static Future<void> createNewRoom(BuildContext context) async {
    final user = _getUser(context);
    await _rooms.add(OnlineRoomMetaData.newSingle(user.uid).toMap());
  }

  ///Online Full Room
  static Future<RoomData> enterRoom(String roomId) async {
    final profile = Profile.global;
    if (profile == null) throw 'You are not logged in';
    final metaData = await getRoomMetaData(roomId);
    if (metaData.players.length < 1) throw 'not enough players in room';
    if (metaData.players.length == 2 && !metaData.players.contains(profile.id))
      throw 'room is already full';
    if (metaData.players.length == 1 && metaData.players.contains(profile.id))
      throw 'Cannot enter as not enough players';
    late final RoomData roomData;
    try {
      roomData = await getRoomData(roomId);
    } catch (error) {
      roomData = await createNewRoomData(metaData, profile.id);
    }
    return roomData;
  }

  static Future<RoomData> getRoomData(String roomId) async {
    final snapshot = await _rooms.doc('$roomId$_roomDataPath').get();
    if (!snapshot.exists) throw 'room data does not exists';
    late final RoomData roomData;
    try {
      roomData = RoomData.fromMap(snapshot.data()!);
    } catch (error) {
      print(error);
      throw 'corrupted room data';
    }
    return roomData;
  }

  static Future<RoomData> createNewRoomData(
      OnlineRoomMetaData metaData, String playerId) async {
    if (metaData.id == null) throw 'corrupted metaData';
    await _rooms.doc(metaData.id).update({
      "players": FieldValue.arrayUnion([playerId]),
    });
    final callable = _functions.httpsCallable('createNewRoomData');
    await callable(metaData.id);
    return await getRoomData(metaData.id!);
  }

  static Future<void> deleteRoom(String roomId) async {
    final callable = _functions.httpsCallable('deleteRoom');
    await callable(roomId);
  }

  static Stream<DocumentSnapshot> roomStream(String roomId) {
    return _rooms.doc('$roomId$_roomDataPath').snapshots();
  }

  static Future<void> updateRoom(RoomData roomData) async {
    final snapshot = await _rooms.doc(roomData.id).get();
    if (!snapshot.exists) throw 'room does not exist';

    final batch = _firestore.batch();
    final Map<String, dynamic> roomDataUpdate = {
      RoomDataLabels.currentBoard: roomData.currentBoard.flat,
    };

    if (roomData.lastMoves.last.playerIdTurn == roomData.whitePlayer.id)
      roomDataUpdate[RoomDataLabels.whiteTotalDuration] =
          roomData.whiteTotalDuration.inSeconds;
    else
      roomDataUpdate[RoomDataLabels.blackTotalDuration] =
          roomData.blackTotalDuration.inSeconds;

    batch.update(_rooms.doc('${roomData.id}$_roomDataPath'), roomDataUpdate);

    batch.set(_rooms.doc('${roomData.id}$_lastMovesPath/${roomData.lastMoves.last.id}'),
        roomData.lastMoves.last.toMap());

    await batch.commit();
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
