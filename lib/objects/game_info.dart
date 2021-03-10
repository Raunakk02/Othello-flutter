import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/flip_piece.dart';
import 'package:othello/components/piece.dart';
import 'package:othello/utils/globals.dart';

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

class GameInfo {
  GameInfo(int boardHeight, int boardLength)
      : this.boardHeight = max(2, boardHeight),
        this.boardLength = max(2, boardLength) {
    _initValues();
    _initBoard();
  }

  final int boardHeight, boardLength;
  late double _boardWidth;
  late double cellWidth;
  List<List<List<int>>> _board = [[]];
  List<List<FlipPieceState?>> flipPieceStates = [];
  List<List<PieceState?>> pieceStates = [];
  bool _flipping = false;

  List<List<int>> get board => _board.last;

  void _initValues() {
    _boardWidth = Globals.screenWidth - 50;
    cellWidth = _boardWidth / boardLength;
    for (int i = 0; i < boardHeight; i++) {
      flipPieceStates.add([]);
      flipPieceStates[i].length = boardLength;
      pieceStates.add([]);
      pieceStates[i].length = boardLength;
      board.add([]);
      for (int j = 0; j < boardLength; j++) board[i].add(-1);
    }
  }

  void _initBoard() {
    int lMidFirst = boardLength ~/ 2 - 1,
        lMidSecond = boardLength ~/ 2,
        hMidFirst = boardHeight ~/ 2 - 1,
        hMidSecond = boardHeight ~/ 2;
    board[hMidFirst][lMidFirst] = 0;
    board[hMidSecond][lMidSecond] = 0;
    board[hMidFirst][lMidSecond] = 1;
    board[hMidSecond][lMidFirst] = 1;

    WidgetsBinding.instance!.addPostFrameCallback((_) => _markPossibleMoves());
  }

  void undo() {
    if (_board.length <= 1) return;
    _board.removeLast();

    PieceState.whiteTurn = !PieceState.whiteTurn;
    if (!_flipping) _syncEachPiece();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _markPossibleMovesOrEndGame();
    });
  }

  Function(PieceState state) onTapOnPiece(int i, int j, BuildContext context) =>
      (state) async {
        _board.add(board.clone);
        board[i][j] = state.boardValue;
        var piecesToFlip = _getPiecesToFlip(i, j, board[i][j]);
        _flipPieces(piecesToFlip);
        _markPossibleMovesOrEndGame(context: context);
        await _startFlipAnimation(piecesToFlip);
      };

  ///If there is a possibility of End Game do not left context null.
  void _markPossibleMovesOrEndGame({BuildContext? context}) {
    if (!_markPossibleMoves()) {
      PieceState.whiteTurn = !PieceState.whiteTurn;
      if (!_markPossibleMoves() && context != null) _endGame(context);
    }
  }

  void _endGame(BuildContext context) {
    final _totalPieces = getTotalPieces();
    final _status = _getStatus(_totalPieces);
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

  List<int> getTotalPieces() {
    List<int> res = [0, 0, 0];
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == 0)
          res[0]++;
        else if (board[i][j] == 1)
          res[1]++;
        else
          res[2]++;
      }
    }
    return res;
  }

  ///-1 for tie
  ///0 for White win
  ///1 for black win
  int _getStatus(List<int> totalPieces) {
    assert(totalPieces.length == 3);
    if (totalPieces[0] == totalPieces[1]) return -1;
    return totalPieces[0] > totalPieces[1] ? 0 : 1;
  }

  void _flipPieces(List<List<List<int>>?> piecesToFlip) {
    for (var levelPieces in piecesToFlip)
      if (levelPieces != null)
        for (var pair in levelPieces) {
          int i = pair.first, j = pair.last;
          board[i][j] = 1 - board[i][j];
        }
  }

  bool _markPossibleMoves({bool? whiteTurn}) {
    int value = whiteTurn ?? PieceState.whiteTurn ? 0 : 1;
    bool havePossibleMove = false;
    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) {
        if (board[i][j] != -1) continue;
        bool setThisCellState = false;
        if (pieceStates[i][j]?.possibleMove ?? true) {
          pieceStates[i][j]!.possibleMove = false;
          setThisCellState = true;
        }
        if (_getPiecesToFlip(i, j, value).length > 0) {
          pieceStates[i][j]!.possibleMove = true;
          setThisCellState = true;
          havePossibleMove = true;
        }
        if (setThisCellState) pieceStates[i][j]?.stateFn(operate: false);
      }
    return havePossibleMove;
  }

  Future<void> _startFlipAnimation(List<List<List<int>>?> piecesToFlip) async {
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
  }

  void _syncEachPiece() {
    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) pieceStates[i][j]?.set(board[i][j]);
  }

  List<List<List<int>>?> _getPiecesToFlip(int mainI, int mainJ, int value) {
    final maxDepth = max(boardHeight, boardLength);
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
              currentI >= boardHeight ||
              currentJ < 0 ||
              currentJ >= boardLength ||
              board[currentI][currentJ] == -1) {
            step = -1;
            continue;
          }
          if ((step == 1 && board[currentI][currentJ] == value)) {
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
}
