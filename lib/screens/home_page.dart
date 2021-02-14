import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:othello/components/piece.dart';

class HomePage extends StatefulWidget {
  HomePage(this.screenWidth);

  final double screenWidth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const boardLength = 8, boardHeight = 8;
  double boardWidth;
  double cellWidth;
  List<Widget> mainStack;
  List<List<int>> board = [];
  List<List<bool>> flipping = [];
  List<List<Function({bool operate})>> flipStateFns = [];
  List<List<PieceState>> pieceStates = [];

  @override
  void initState() {
    boardWidth = widget.screenWidth - 50;
    cellWidth = boardWidth / boardLength;
    flipStateFns.length = boardHeight;
    flipping.length = boardHeight;
    pieceStates.length = boardHeight;
    for (int i = 0; i < boardHeight; i++) {
      flipStateFns[i] = [];
      flipStateFns[i].length = boardLength;
      flipping[i] = [];
      flipping[i].length = boardLength;
      pieceStates[i] = [];
      pieceStates[i].length = boardLength;
      board.add([]);
      for (int j = 0; j < boardLength; j++) board[i].add(-1);
    }

    initBoard();
    super.initState();
  }

  void initBoard() {
    board[3][3] = 0;
    board[4][4] = 0;
    board[3][4] = 1;
    board[4][3] = 1;

    WidgetsBinding.instance.addPostFrameCallback((_) => _markPossibleMoves());
  }

  @override
  Widget build(BuildContext context) {
    mainStack = [
      Column(
        children: List.generate(
            boardHeight,
            (i) => Row(
                  children: List.generate(
                      boardLength,
                      (j) => Piece(
                            cellWidth,
                            initValue: board[i][j],
                            initState: (state) => pieceStates[i][j] = state,
                            flip: () async {
                              board[i][j] = pieceStates[i][j].boardValue;
                              var piecesToFlip =
                                  _getPiecesToFlip(i, j, board[i][j]);
                              _flipPieces(piecesToFlip);
                              _markPossibleMoves();
                              await _startFlipAnimation(piecesToFlip);
                            },
                          )),
                )),
      ),
    ];

    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) mainStack.add(_flipPiece(i, j));

    return Scaffold(
      appBar: AppBar(title: Text("Othello Game")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Container(
            color: Colors.brown,
            padding: const EdgeInsets.all(10),
            child: Container(
              width: widget.screenWidth - 50,
              height: widget.screenWidth - 50,
              color: Colors.green[600],
              child: Stack(
                children: mainStack,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _flip(int i, int j) {
    flipStateFns[i][j]();
    pieceStates[i][j].stateFn();
  }

  Widget _flipPiece(int i, int j) {
    flipping[i][j] = false;
    return Positioned(
      left: cellWidth * j,
      top: cellWidth * i - (((cellWidth * (90 / 74)) - cellWidth) / 2),
      child: IgnorePointer(
        child: StatefulBuilder(builder: (context, state) {
          flipStateFns[i][j] = ({operate = true}) {
            if (operate) flipping[i][j] = !flipping[i][j];
            state(() {});
          };
          return flipping[i][j] ? _flipAnimation(i, j) : Container();
        }),
      ),
    );
  }

  Widget _flipAnimation(int i, int j) {
    final _onFinishPlaying = (state) {
      if (pieceStates[i][j].value % 2 == 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        flipStateFns[i][j]();
        pieceStates[i][j].stateFn();
      });
    };
    return Container(
      width: cellWidth,
      height: cellWidth * (90 / 74),
      child: FittedBox(
        child: InkWell(
          child: ImageSequenceAnimator(
            board[i][j] == 1 ? "assets/flip_0" : 'assets/flip_1',
            "frame_",
            0,
            1,
            "png",
            19,
            fps: 50,
            waitUntilCacheIsComplete: true,
            onFinishPlaying: _onFinishPlaying,
          ),
        ),
      ),
    );
  }

  void _markPossibleMoves() {
    int value = PieceState.whiteTurn ? 0 : 1;
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
        }
        if (setThisCellState) pieceStates[i][j].stateFn(operate: false);
      }
  }

  void _flipPieces(List<List<List<int>>> piecesToFlip) {
    for (var levelPieces in piecesToFlip)
      for (var pair in levelPieces) {
        int i = pair.first, j = pair.last;
        board[i][j] = 1 - board[i][j];
      }
  }

  Future<void> _startFlipAnimation(List<List<List<int>>> piecesToFlip) async {
    for (var levelPieces in piecesToFlip) {
      for (var pair in levelPieces) _flip(pair.first, pair.last);

      await Future.delayed(Duration(milliseconds: 100));
    }
    await Future.delayed(Duration(milliseconds: 400));
  }

  List<List<List<int>>> _getPiecesToFlip(int mainI, int mainJ, int value) {
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
          if (k > 8 || k < -8) {
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
