import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:othello/components/flip_piece.dart';
import 'package:othello/components/piece.dart';
import 'package:othello/utils/globals.dart';

extension on List<List<int>> {
  List<List<int>> get clone {
    List<List<int>> res = [];
    for (int i = 0; i < this.length; i++){
      res.add([]);
      for (int j = 0; j < this[i].length; j++)
        res[i].add(this[i][j]);
    }
    return res;
  }
}

class GameInfo {
  GameInfo(this.boardHeight, this.boardLength) {
    _initValues();
    _initBoard();
  }

  final int boardHeight, boardLength;
  double _boardWidth;
  double cellWidth;
  List<List<List<int>>> _board = [[]];
  List<List<FlipPieceState>> flipPieceStates = [];
  List<List<PieceState>> pieceStates = [];

  List<List<int>> get board => _board.last;

  void _initValues() {
    _boardWidth = Globals.screenWidth - 50;
    cellWidth = _boardWidth / boardLength;
    flipPieceStates.length = boardHeight;
    pieceStates.length = boardHeight;
    for (int i = 0; i < boardHeight; i++) {
      flipPieceStates[i] = [];
      flipPieceStates[i].length = boardLength;
      pieceStates[i] = [];
      pieceStates[i].length = boardLength;
      board.add([]);
      for (int j = 0; j < boardLength; j++) board[i].add(-1);
    }
  }

  void _initBoard() {
    board[3][3] = 0;
    board[4][4] = 0;
    board[3][4] = 1;
    board[4][3] = 1;

    WidgetsBinding.instance.addPostFrameCallback((_) => _markPossibleMoves());
  }

  void undo() {
    if (_board.length <= 1) return;
    _board.removeLast();

    PieceState.whiteTurn = !PieceState.whiteTurn;

    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) pieceStates[i][j].set(board[i][j]);

    WidgetsBinding.instance.addPostFrameCallback((_) => _markPossibleMoves());
  }

  Function(PieceState state) onTapOnPiece(int i, int j) => (state) async {
        _board.add(board.clone);
        board[i][j] = state.boardValue;
        var piecesToFlip = _getPiecesToFlip(i, j, board[i][j]);
        _flipPieces(piecesToFlip);
        if (!_markPossibleMoves()) {
          PieceState.whiteTurn = !PieceState.whiteTurn;
          _markPossibleMoves();
        }
        await _startFlipAnimation(piecesToFlip);
      };

  void _flipPieces(List<List<List<int>>> piecesToFlip) {
    for (var levelPieces in piecesToFlip)
      for (var pair in levelPieces) {
        int i = pair.first, j = pair.last;
        board[i][j] = 1 - board[i][j];
      }
  }

  bool _markPossibleMoves() {
    int value = PieceState.whiteTurn ? 0 : 1;
    bool havePossibleMove = false;
    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) {
        if (board[i][j] != -1) continue;
        bool setThisCellState = false;
        if (pieceStates[i][j].possibleMove) {
          pieceStates[i][j].possibleMove = false;
          setThisCellState = true;
        }
        if (_getPiecesToFlip(i, j, value).length > 0) {
          pieceStates[i][j].possibleMove = true;
          setThisCellState = true;
          havePossibleMove = true;
        }
        if (setThisCellState) pieceStates[i][j].stateFn(operate: false);
      }
    return havePossibleMove;
  }

  Future<void> _startFlipAnimation(List<List<List<int>>> piecesToFlip) async {
    for (var levelPieces in piecesToFlip) {
      for (var pair in levelPieces)
        flipPieceStates[pair.first][pair.last].flip();

      await Future.delayed(Duration(milliseconds: 100));
    }
    await Future.delayed(Duration(milliseconds: 400));
  }

  List<List<List<int>>> _getPiecesToFlip(int mainI, int mainJ, int value) {
    final maxDepth = max(boardHeight, boardLength);
    int currentI = mainI, currentJ = mainJ, step;
    bool flipping = true;
    List<List<List<int>>> piecesToFlip = [];
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
          piecesToFlip[k].add([currentI, currentJ]);
        }
      }
    }
    return piecesToFlip;
  }
}