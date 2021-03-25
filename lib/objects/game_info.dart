import 'dart:collection';

import 'package:flutter/cupertino.dart';
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
    _boardWidth = Globals.screenWidth - 50;
    cellWidth = _boardWidth / _roomData.length;
    for (int i = 0; i < _roomData.height; i++) {
      flipPieceStates.add([]);
      flipPieceStates[i].length = _roomData.length;
      pieceStates.add([]);
      pieceStates[i].length = _roomData.length;
    }
  }

  void undo() {
    _roomData.undo();
    if (!_flipping) _syncEachPiece();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _markPossibleMovesOrEndGame();
    });
  }

  Function(PieceState state) onTapOnPiece(int i, int j,
          [bool moveFromBot = false]) =>
      (state) async {
        if (!moveFromBot && !_roomData.isManualTurn) return;
        state.set(_roomData.currentPlayerMove);
        var piecesToFlip = _roomData.makeMove(i, j);
        await _startFlipAnimation(piecesToFlip);
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
      int i = possibleMove[0], j = possibleMove[1];
      pieceStates[i][j]!.possibleMove = true;
      pieceStates[i][j]?.stateFn(operate: false);
      havePossibleMove = true;
    }
    return havePossibleMove;
  }

  Future<void> _startFlipAnimation(List<List<List<int>>?> piecesToFlip) async {
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
    _syncEachPiece();
    _flipping = false;
    if (!_roomData.isManualTurn && !gameEnded) {
      var nextMove = await _roomData.nextTurn;
      print("is not manual turn, next moves: $nextMove");
      if (nextMove == null || nextMove.length < 2) return;
      onTapOnPiece(nextMove[0], nextMove[1], true)(
          pieceStates[nextMove[0]][nextMove[1]]!);
    }
  }

  void _syncEachPiece() {
    for (int i = 0; i < _roomData.height; i++)
      for (int j = 0; j < _roomData.length; j++)
        pieceStates[i][j]?.set(board[i][j]);
  }
}
