import 'dart:collection';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/flip_piece.dart';
import 'package:othello/components/piece.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/utils/globals.dart';

class GameInfo {
  GameInfo(this._roomData, this._context) {
    _initValues();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _markPossibleMoves());
  }

  final BuildContext _context;
  late double _boardWidth;
  late double cellWidth;
  RoomData _roomData;
  List<List<FlipPieceState?>> flipPieceStates = [];
  List<List<PieceState?>> pieceStates = [];
  bool _flipping = false;

  int get boardHeight => _roomData.height;

  int get boardLength => _roomData.length;

  RoomData get roomData => _roomData;

  UnmodifiableListView<UnmodifiableListView<int>> get board =>
      _roomData.currentBoard;

  void _initValues() {
    final margin = 50;
    if (Globals.screenWidth < Globals.screenHeight) {
      _boardWidth = Globals.screenWidth - margin;
      final _hasEnoughHeight = Globals.screenHeight > Globals.screenWidth * 1.5;
      if (!_hasEnoughHeight) _boardWidth -= Globals.screenWidth * 0.2;
    } else {
      final appBarHeight = 100;
      _boardWidth = Globals.screenHeight - margin - 100;
      if (!kIsWeb) _boardWidth -= appBarHeight;
    }

    cellWidth = _boardWidth / _roomData.length;
    for (int i = 0; i < _roomData.height; i++) {
      flipPieceStates.add([]);
      flipPieceStates[i].length = _roomData.length;
      pieceStates.add([]);
      pieceStates[i].length = _roomData.length;
    }
  }

  void undo({bool debug = false}) {
    if (_roomData.isOnline) return;
    if (debug) print("performing undo");
    _roomData.undo(debug: debug);
    if (!_flipping) _syncEachPiece(false, debug);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (debug) print("marking possible moves");
      _markPossibleMovesOrEndGame();
      _roomData.lastMovesStats(debug);
    });
  }

  Future<void> Function(PieceState state) onTapOnPiece(int i, int j,
      [bool moveFromBot = false, bool debug = false]) =>
          (state) async {
        state.set(_roomData.currentPlayerMove);
        var piecesToFlip = _roomData.makeMove(i, j);
        await _startFlipAnimation(piecesToFlip, debug);
      };

  ///If there is a possibility of End Game do not left context null.
  ///
  /// If game end return true.
  bool _markPossibleMovesOrEndGame({BuildContext? context}) {
    if (!_markPossibleMoves() && context != null) {
      _endGame(context);
      return true;
    }
    return false;
  }

  void _endGame(BuildContext context) {
    final _status = _roomData.getStatus();
    showDialog(
        context: context,
        builder: (context) {
          String title = "TIE";
          if (_status == 0)
            title = "WHITE WINS";
          else if (_status == 1) title = "BLACK WINS";
          return CommonAlertDialog(title);
        });
  }

  bool _markPossibleMoves() {
    var possibleMoves = _roomData.getPossibleMovesList();
    bool havePossibleMove = false;
    for (int i = 0; i < boardHeight; i++) {
      for (int j = 0; j < boardLength; j++) {
        if (pieceStates[i][j]?.possibleMove ?? true) {
          pieceStates[i][j]!.possibleMove = false;
          pieceStates[i][j]?.stateFn(operate: false);
        }
      }
    }
    for (var possibleMove in possibleMoves) {
      int i = possibleMove[0],
          j = possibleMove[1];
      pieceStates[i][j]!.possibleMove = true;
      pieceStates[i][j]?.stateFn(operate: false);
      havePossibleMove = true;
    }
    return havePossibleMove;
  }

  Future<void> _startFlipAnimation(List<List<List<int>>?> piecesToFlip, bool debug) async {
    bool gameEnded = _markPossibleMovesOrEndGame(context: _context);
    if (_flipping) return;
    _flipping = true;
    for (var levelPieces in piecesToFlip) {
      if (levelPieces != null)
        for (var pair in levelPieces)
          flipPieceStates[pair.first][pair.last]?.flip();

      await Future.delayed(Duration(milliseconds: 100));
    }
    await Future.delayed(Duration(milliseconds: 400));
    _syncEachPiece(gameEnded, debug);
    _flipping = false;
  }

  void _syncEachPiece(bool gameEnded, bool debug) {
    for (int i = 0; i < _roomData.height; i++)
      for (int j = 0; j < _roomData.length; j++)
        pieceStates[i][j]?.set(board[i][j]);
    makeNextTurn(gameEnded, debug: debug);
  }

  Future<void> makeNextTurn(bool gameEnded, {bool debug = false}) async {
    if (debug) log("whiteTurn: ${_roomData.isWhiteTurn}, manualTurn: ${_roomData
        .isManualTurn}, gameEnded: $gameEnded", name: "makeNextTurn");
    if (!_roomData.isManualTurn && !gameEnded) {
      var nextMove = await _roomData.nextTurn;
      print("is not manual turn, next move: $nextMove");
      if (nextMove != null && nextMove.length >= 2) {
        await onTapOnPiece(nextMove[0], nextMove[1], true, debug)(
            pieceStates[nextMove[0]][nextMove[1]]!);
      }
    }
  }
}
