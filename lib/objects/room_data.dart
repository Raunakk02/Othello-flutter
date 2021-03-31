import 'dart:collection';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:othello/objects/profile.dart';
import 'package:othello/utils/networks.dart';

import 'chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'move_data.dart';
import 'player.dart';
import 'savable.dart';

part 'next_move_fns.dart';

extension boardExtensions on List<List<int>> {
  List<List<int>> get clone {
    List<List<int>> res = [];
    for (int i = 0; i < this.length; i++) {
      res.add([]);
      for (int j = 0; j < this[i].length; j++) res[i].add(this[i][j]);
    }
    return res;
  }

  List<int> get flat {
    List<int> res = [];
    for (int i = 0; i < this.length; i++) {
      for (int j = 0; j < this[i].length; j++) res.add(this[i][j]);
    }
    return res;
  }
}

UnmodifiableListView<UnmodifiableListView<int>> fromFlatList(
    List<int> flat, int width, int height) {
  List<UnmodifiableListView<int>> res = [];
  for (int i = 0; i < flat.length; i++) {
    List<int> temp = [];
    if ((i + 1) % width == 0) {
      res.add(UnmodifiableListView(temp));
      temp.clear();
      temp.add(flat[i]);
    } else
      temp.add(flat[i]);
  }
  return UnmodifiableListView(res);
}

abstract class RoomDataLabels {
  static const roomId = 'roomId',
      blackPlayer = 'blackPlayer',
      length = 'length',
      height = 'height',
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
    required this.id,
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
        this.length = ((currentBoard?.length ?? 0) > 1)
            ? (currentBoard?[0].length ?? length)
            : length,
        this.height = currentBoard?.length ?? height,
        this._timestamp = timestamp ?? DateTime.now(),
        this._currentBoard = currentBoard ?? initializeBoard(length, height),
        this.__playerIdTurn = whiteFirstTurn ? whitePlayer.id : blackPlayer.id,
        this._lastMoves = lastMoves ?? [],
        this._chats = chats ?? [],
        this._blackTotalDuration = blackTotalDuration,
        this._whiteTotalDuration = whiteTotalDuration {
    this._playerIdTurn =
        this.__playerIdTurn; //To call set method for playerIdTurn
    _updateLastMoves();
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
      id: hiveOfflinePvPKey,
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
      id: hiveOfflinePvCKey,
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
    DateTime timestamp;
    int length = map[RoomDataLabels.length] ?? 8,
        height = map[RoomDataLabels.height] ?? 8;
    List<List<int>>? currentBoard = fromFlatList(
        map[RoomDataLabels.currentBoard]?.cast<int>()?.toList() ?? [],
        length,
        height);

    if (currentBoard.length == 0) currentBoard = null;

    final gotTimestamp = map[RoomDataLabels.timestamp];
    if (gotTimestamp is DateTime)
      timestamp = gotTimestamp;
    else
      timestamp = gotTimestamp.toDate();

    return RoomData._raw(
      id: map[RoomDataLabels.roomId],
      length: length,
      height: height,
      hiveKey: map[RoomDataLabels.hiveKey] ?? hiveOfflinePvPKey,
      blackPlayer: Player.fromMap(map[RoomDataLabels.blackPlayer] ?? {}),
      whitePlayer: whitePlayer,
      timestamp: timestamp,
      currentBoard: currentBoard,
      lastMoves: MoveData.fromMaps(
          map[RoomDataLabels.lastMoves]?.cast<Map>()?.toList() ?? [],
          length,
          height),
      chats: ChatMessage.fromMaps(
          map[RoomDataLabels.chats]?.cast<Map>()?.toList() ?? []),
      blackTotalDuration:
          Duration(seconds: map[RoomDataLabels.blackTotalDuration] ?? 0),
      whiteTotalDuration:
          Duration(seconds: map[RoomDataLabels.whiteTotalDuration] ?? 0),
      whiteFirstTurn: whiteTurn,
    );
  }

  static const hiveBoxName = 'Rooms';
  static const hiveOfflinePvPKey = 'offlinePvP';
  static const hiveOfflinePvCKey = 'offlinePvC';
  final String id, hiveKey;
  final Player blackPlayer, whitePlayer;
  final int height, length;
  String __playerIdTurn;
  List<List<int>> _currentBoard;
  List<MoveData> _lastMoves;
  Duration _blackTotalDuration, _whiteTotalDuration;
  List<ChatMessage> _chats;
  DateTime _timestamp;

  int get currentPlayerMove => _playerMove(isWhiteTurn);

  static int _playerMove(bool whiteTurn) => whiteTurn ? 0 : 1;

  String playerId(bool isWhiteTurn) =>
      isWhiteTurn ? whitePlayer.id : blackPlayer.id;

  bool get isWhiteTurn => _playerIdTurn == whitePlayer.id;

  bool get isManualTurn =>
      _currentPlayer.nextMoveFnId == null ||
      (_currentPlayer.nextMoveFnId == NextMoveFns.onlineId &&
          _playerIdTurn == Profile.global?.id);

  Player get _currentPlayer => isWhiteTurn ? whitePlayer : blackPlayer;

  String get _playerIdTurn => __playerIdTurn;

  set _playerIdTurn(String str) {
    __playerIdTurn = str;
    notifyListeners();
  }

  Duration get blackTotalDuration => _blackTotalDuration;

  Duration get whiteTotalDuration => _whiteTotalDuration;

  Duration getTotalDuration(bool forWhite) =>
      forWhite ? _whiteTotalDuration : blackTotalDuration;

  UnmodifiableListView<ChatMessage> get chats => UnmodifiableListView(_chats);

  UnmodifiableListView<MoveData> get lastMoves =>
      UnmodifiableListView(_lastMoves);

  DateTime get timestamp => _timestamp;

  bool get isOnline {
    return whitePlayer.nextMoveFnId == NextMoveFns.onlineId ||
        blackPlayer.nextMoveFnId == NextMoveFns.onlineId;
  }

  UnmodifiableListView<UnmodifiableListView<int>> get currentBoard {
    final clone = _currentBoard.clone;
    List<UnmodifiableListView<int>> res = [];
    for (int i = 0; i < height; i++)
      res.add(UnmodifiableListView(clone[i]));
    return UnmodifiableListView(res);
  }

  Future<List<int>?> get nextTurn => _currentPlayer.nextTurn(this);

  void _subtractDuration(String playerIdTurn, Duration duration) {
    if (playerIdTurn == whitePlayer.id)
      _whiteTotalDuration -= duration;
    else if (playerIdTurn == blackPlayer.id) _blackTotalDuration -= duration;
  }

  Map<String, dynamic> toMap() => {
        RoomDataLabels.roomId: id,
        RoomDataLabels.hiveKey: hiveKey,
        RoomDataLabels.length: length,
        RoomDataLabels.height: height,
        RoomDataLabels.blackPlayer: blackPlayer.toMap(),
        RoomDataLabels.whitePlayer: whitePlayer.toMap(),
        RoomDataLabels.playerIdTurn: __playerIdTurn,
        RoomDataLabels.currentBoard: _currentBoard.flat,
        RoomDataLabels.lastMoves: lastMoves.toMaps(),
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

  static List<List<int>> initializeBoard(int length, int height) {
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

  void undo({bool debug = false}) {
    if (lastMoves.length < 2) return;
    _lastMoves.removeLast();
    _currentBoard = lastMoves.last.board.clone;
    _playerIdTurn = lastMoves.last.playerIdTurn;
    _subtractDuration(playerId(!isWhiteTurn), lastMoves.last.duration);
    _timestamp = lastMoves.last.timestamp;
    if (!isManualTurn) return undo();
    _saveGameOffline();
    _updateGameOnlineIfRequired();
    lastMovesStats(debug);
  }

  List<List<List<int>>?> makeMove(int i, int j, {bool debug = false}) {
    lastMovesStats(debug);
    _currentBoard[i][j] = currentPlayerMove;
    var piecesToFlip = getPiecesToFlip(i, j, _currentBoard[i][j]);
    if (isWhiteTurn)
      _whiteTotalDuration += DateTime.now().difference(_timestamp);
    else
      _blackTotalDuration += DateTime.now().difference(_timestamp);
    _flipPieces(piecesToFlip);
    _timestamp = DateTime.now();
    changeTurn();
    _updateLastMoves();
    _saveGameOffline();
    _updateGameOnlineIfRequired();
    return piecesToFlip;
  }

  void _saveGameOffline() async {
    if (isOnline) return;
    var box = Hive.box(hiveBoxName);
    await box.put(hiveKey, toMap());
    print("successfully saved");
  }

  void _updateGameOnlineIfRequired() async {
    if (!isOnline) return;

    await Networks.updateRoom(this);
  }

  void _updateLastMoves({bool debug = false}) {
    if (debug) dev.log('isWhiteTurn: $isWhiteTurn', name: '_updateLastMoves');
    final currentMove = MoveData(
        board: currentBoard,
        duration: DateTime.now().difference(_timestamp),
        playerIdTurn: _playerIdTurn,
        timestamp: _timestamp);
    _lastMoves.add(currentMove);
    lastMovesStats(debug);
  }

  void lastMovesStats(bool debug) {
    if (!debug) return;
    dev.log(
        'lastMove.length: ${lastMoves.length} lastMoves: ${lastMoves.print()}',
        name: "lastMovesStatus");
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
