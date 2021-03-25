import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:othello/components/piece.dart';
import 'player.dart';
import 'savable.dart';

extension on List<List<int>> {
  List<List<int>> get clone {
    List<List<int>> res = [];
    for (int i = 0; i < this.length; i++) {
      res.add([]);
      for (int j = 0; j < this[i].length; j++) res[i].add(this[i][j]);
    }
    return res;
  }
}

abstract class RoomDataLabels {
  static const roomId = 'roomId',
      blackPlayer = 'blackPlayer',
      hiveKey = 'hiveKey',
      whitePlayer = 'whitePlayer',
      playerIdTurn = 'playerIdTurn',
      currentBoard = 'currentBoard',
      lastMoves = 'lastMoves',
      blackTotalDuration = 'blackTotalDuration',
      whiteTotalDuration = 'whiteTotalDuration',
      chats = 'chats',
      timestamp = 'timestamp';
}

class RoomData extends ChangeNotifier with Savable {
  RoomData._raw({
    required this.roomId,
    required this.hiveKey,
    required this.blackPlayer,
    required this.whitePlayer,
    DateTime? timestamp,
    List<List<int>>? currentBoard,
    int length = 8,
    int height = 8,
    List<MoveData>? lastMoves,
    List<ChatMessage>? chats,
    Duration blackTotalDuration = const Duration(),
    Duration whiteTotalDuration = const Duration(),
    bool whiteFirstTurn = false,
  })  : assert(blackPlayer.id != whitePlayer.id),
        this.length = currentBoard?[0].length ?? length,
        this.height = currentBoard?.length ?? height,
        this._timestamp = timestamp ?? DateTime.now(),
        this._currentBoard = currentBoard ?? _initializeBoard(length, height),
        this.__playerIdTurn = whiteFirstTurn ? whitePlayer.id : blackPlayer.id,
        this._lastMoves = lastMoves ?? [],
        this._chats = chats ?? [],
        this._blackTotalDuration = blackTotalDuration,
        this._whiteTotalDuration = whiteTotalDuration {
    PieceState.whiteTurn = isWhiteTurn;
  }

  factory RoomData.fromKey(String key,
      {bool resetGame = false,
      height = 8,
      length = 8,
      whiteFirstTurn = false}) {
    switch (key) {
      case hiveOfflinePvCKey:
        return RoomData.offlinePvC(
            height: height,
            length: length,
            whiteFirstTurn: whiteFirstTurn,
            resetGame: resetGame);

      default:
        return RoomData.offlinePvP(
          height: height,
          length: length,
          whiteFirstTurn: whiteFirstTurn,
          resetGame: resetGame,
        );
    }
  }

  factory RoomData.offlinePvP(
      {bool resetGame = false,
      int height = 8,
      int length = 8,
      bool whiteFirstTurn = false}) {
    if (!resetGame) {
      var room = fromStorage(hiveOfflinePvPKey);
      if (room != null) return room;
    }

    height = max(2, height);
    length = max(2, length);
    return RoomData._raw(
      roomId: hiveOfflinePvPKey,
      hiveKey: hiveOfflinePvPKey,
      blackPlayer: Player(),
      whitePlayer: Player(),
      whiteFirstTurn: whiteFirstTurn,
      height: height,
      length: length,
    );
  }

  factory RoomData.offlinePvC(
      {int height = 8,
      int length = 8,
      bool resetGame = false,
      bool whiteFirstTurn = false,
      bool mainPlayerIsWhite = false}) {
    if (!resetGame) {
      var room = fromStorage(hiveOfflinePvCKey);
      if (room != null) return room;
    }

    Player computerPlayer = Player(nextMoveFnId: NextMoveFns.offlineTempId),
        mainPlayer = Player();

    return RoomData._raw(
      roomId: hiveOfflinePvCKey,
      hiveKey: hiveOfflinePvCKey,
      blackPlayer: mainPlayerIsWhite ? computerPlayer : mainPlayer,
      whitePlayer: mainPlayerIsWhite ? mainPlayer : computerPlayer,
      whiteFirstTurn: whiteFirstTurn,
      height: height,
      length: length,
    );
  }

  static RoomData? fromStorage(String hiveKey) {
    var box = Hive.box(hiveBoxName);
    var _rawData = box.get(hiveKey);
    if (_rawData != null) {
      var map = Map<String, dynamic>.from(_rawData);
      return RoomData.fromMap(map);
    }
  }

  factory RoomData.fromMap(Map<String, dynamic> map) {
    String playerTurnId = map[RoomDataLabels.playerIdTurn];
    Player whitePlayer = Player.fromMap(map[RoomDataLabels.whitePlayer] ?? {});
    bool whiteTurn = playerTurnId == whitePlayer.id;

    return RoomData._raw(
      roomId: map[RoomDataLabels.roomId],
      hiveKey: map[RoomDataLabels.hiveKey] ?? hiveOfflinePvPKey,
      blackPlayer: Player.fromMap(map[RoomDataLabels.blackPlayer] ?? {}),
      whitePlayer: whitePlayer,
      timestamp: map[RoomDataLabels.timestamp],
      currentBoard:
          map[RoomDataLabels.currentBoard]?.cast<List<int>>()?.toList(),
      lastMoves: MoveData.fromMaps(
          map[RoomDataLabels.lastMoves]?.cast<Map>()?.toList() ?? []),
      chats: ChatMessage.fromMaps(
          map[RoomDataLabels.chats]?.cast<Map>()?.toList() ?? []),
      blackTotalDuration:
          Duration(seconds: map[RoomDataLabels.blackTotalDuration]),
      whiteTotalDuration:
          Duration(seconds: map[RoomDataLabels.whiteTotalDuration]),
      whiteFirstTurn: whiteTurn,
    );
  }

  static const hiveBoxName = 'Rooms';
  static const hiveOfflinePvPKey = 'offlinePvP';
  static const hiveOfflinePvCKey = 'offlinePvC';
  final String roomId, hiveKey;
  final Player blackPlayer, whitePlayer;
  final int height, length;
  String __playerIdTurn;
  List<List<int>> _currentBoard;
  List<MoveData> _lastMoves;
  Duration _blackTotalDuration, _whiteTotalDuration;
  List<ChatMessage> _chats;
  DateTime _timestamp;

  int get currentPlayerMove => _playerMove(isWhiteTurn);

  int _playerMove(bool whiteTurn) => whiteTurn ? 0 : 1;

  bool get isWhiteTurn => _playerIdTurn == whitePlayer.id;

  bool get isManualTurn => _currentPlayer.nextMoveFnId == null;

  Player get _currentPlayer => isWhiteTurn ? whitePlayer : blackPlayer;

  String get _playerIdTurn => __playerIdTurn;

  set _playerIdTurn(String str) {
    __playerIdTurn = str;
    PieceState.whiteTurn = isWhiteTurn;
    notifyListeners();
  }

  Duration get blackTotalDuration => _blackTotalDuration;

  Duration get whiteTotalDuration => _whiteTotalDuration;

  Duration getTotalDuration(bool forWhite) =>
      forWhite ? _whiteTotalDuration : blackTotalDuration;

  UnmodifiableListView<ChatMessage> get chats => UnmodifiableListView(_chats);

  DateTime get timestamp => _timestamp;

  UnmodifiableListView<UnmodifiableListView<int>> get currentBoard {
    List<UnmodifiableListView<int>> res = [];
    for (int i = 0; i < height; i++)
      res.add(UnmodifiableListView(_currentBoard[i]));
    return UnmodifiableListView(res);
  }

  Future<List<int>?> get nextTurn => _currentPlayer.nextTurn(this);

  Map<String, dynamic> toMap() => {
        RoomDataLabels.roomId: roomId,
        RoomDataLabels.hiveKey: hiveKey,
        RoomDataLabels.blackPlayer: blackPlayer.toMap(),
        RoomDataLabels.whitePlayer: whitePlayer.toMap(),
        RoomDataLabels.playerIdTurn: __playerIdTurn,
        RoomDataLabels.currentBoard: _currentBoard,
        RoomDataLabels.lastMoves: _lastMoves.toMaps(),
        RoomDataLabels.blackTotalDuration: _blackTotalDuration.inSeconds,
        RoomDataLabels.whiteTotalDuration: _whiteTotalDuration.inSeconds,
        RoomDataLabels.chats: _chats.toMaps(),
        RoomDataLabels.timestamp: _timestamp,
      };

  int totalPieces({forWhite = true}) {
    int res = 0;
    for (int i = 0; i < height; i++)
      for (int j = 0; j < length; j++)
        if (currentBoard[i][j] == _playerMove(forWhite)) res++;

    return res;
  }

  static List<List<int>> _initializeBoard(int length, int height) {
    List<List<int>> board = [];
    for (int i = 0; i < height; i++) {
      board.add([]);
      for (int j = 0; j < length; j++) board[i].add(-1);
    }

    int lMidSecond = length ~/ 2, hMidSecond = height ~/ 2;
    board[hMidSecond - 1][lMidSecond - 1] = 0;
    board[hMidSecond][lMidSecond] = 0;
    board[hMidSecond - 1][lMidSecond] = 1;
    board[hMidSecond][lMidSecond - 1] = 1;

    return board;
  }

  void changeTurn() {
    _flipTurn();
    var possibleMoves = getPossibleMovesList();
    if (possibleMoves.length <= 0) _flipTurn();
  }

  void _flipTurn() =>
      _playerIdTurn = isWhiteTurn ? blackPlayer.id : whitePlayer.id;

  List<List<int>> getPossibleMovesList() {
    List<List<int>> res = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < length; j++) {
        if (_currentBoard[i][j] != -1) continue;
        if (getPiecesToFlip(i, j, currentPlayerMove).length > 0)
          res.add([i, j]);
      }
    }
    return res;
  }

  void undo() {
    _currentBoard = _lastMoves.last.board;
    _playerIdTurn = _lastMoves.last.playerIdTurn;
    _timestamp = _timestamp.subtract(_lastMoves.last.duration);
    _lastMoves.removeLast();
    _saveGameOffline();
    if (!isManualTurn) undo();
  }

  List<List<List<int>>?> makeMove(int i, int j) {
    _updateLastMoves();
    _currentBoard[i][j] = currentPlayerMove;
    var piecesToFlip = getPiecesToFlip(i, j, _currentBoard[i][j]);
    if (isWhiteTurn)
      _whiteTotalDuration += DateTime.now().difference(_timestamp);
    else
      _blackTotalDuration += DateTime.now().difference(_timestamp);
    _flipPieces(piecesToFlip);
    changeTurn();
    _timestamp = DateTime.now();
    _saveGameOffline();
    return piecesToFlip;
  }

  void _saveGameOffline() async {
    var box = Hive.box(hiveBoxName);
    await box.put(hiveKey, toMap());
    print("successfully saved");
  }

  void _updateLastMoves() {
    final currentMove = MoveData(
        board: _currentBoard.clone,
        duration: DateTime.now().difference(_timestamp),
        playerIdTurn: _playerIdTurn);
    _lastMoves.add(currentMove);
  }

  ///-1 for tie
  ///0 for White win
  ///1 for black win
  int getStatus() {
    final totalPieces = _getTotalPieces();
    assert(totalPieces.length == 3);
    if (totalPieces[0] == totalPieces[1]) return -1;
    return totalPieces[0] > totalPieces[1] ? 0 : 1;
  }

  List<int> _getTotalPieces() {
    List<int> res = [0, 0, 0];
    for (int i = 0; i < _currentBoard.length; i++) {
      for (int j = 0; j < _currentBoard[i].length; j++) {
        if (_currentBoard[i][j] == 0)
          res[0]++;
        else if (_currentBoard[i][j] == 1)
          res[1]++;
        else
          res[2]++;
      }
    }
    return res;
  }

  List<List<List<int>>?> getPiecesToFlip(int mainI, int mainJ, int value) {
    final maxDepth = max(this.height, this.length);
    int currentI = mainI, currentJ = mainJ, step;
    bool flipping = true;
    List<List<List<int>>?> piecesToFlip = [];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        step = 1;
        flipping = false;
        for (int k = 0;; k += step) {
          currentI += step * i;
          currentJ += step * j;
          if (k == -1) break;
          //prevent if any infinite loop happening, even though it should not happen
          if (k > maxDepth || k < -maxDepth) {
            print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
            break;
          }
          if (currentI < 0 ||
              currentI >= this.height ||
              currentJ < 0 ||
              currentJ >= this.length ||
              _currentBoard[currentI][currentJ] == -1) {
            step = -1;
            continue;
          }
          if ((step == 1 && _currentBoard[currentI][currentJ] == value)) {
            step = -1;
            flipping = true;
            continue;
          }
          if (step == 1 || !flipping) continue;
          if (piecesToFlip.length <= k + 1) piecesToFlip.length = k + 1;
          if (piecesToFlip[k] == null) piecesToFlip[k] = [];
          piecesToFlip[k]!.add([currentI, currentJ]);
        }
      }
    }
    return piecesToFlip;
  }

  void _flipPieces(List<List<List<int>>?> piecesToFlip) {
    for (var levelPieces in piecesToFlip)
      if (levelPieces != null)
        for (var pair in levelPieces) {
          int i = pair.first, j = pair.last;
          _currentBoard[i][j] = 1 - _currentBoard[i][j];
        }
  }
}

class MoveData extends Savable {
  MoveData({
    required this.board,
    required this.duration,
    required this.playerIdTurn,
  });

  MoveData.fromMap(Map map)
      : this.board = map['board'].cast<List<int>>().toList(),
        this.duration = Duration(seconds: map['duration']),
        this.playerIdTurn = map['playerIdTurn'];

  static List<MoveData> fromMaps(List<Map> maps) =>
      List.generate(maps.length, (i) => MoveData.fromMap(maps[i]));

  final List<List<int>> board;
  final Duration duration;
  final String playerIdTurn;

  Map<String, dynamic> toMap() => {
        'board': board,
        'duration': duration.inSeconds,
        'playerIdTurn': playerIdTurn,
      };
}

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
        this.timestamp = map['timestamp'];

  final String msg;
  final String uid;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() => {
        'msg': msg,
        'uid': uid,
        'timestamp': timestamp,
      };
}
