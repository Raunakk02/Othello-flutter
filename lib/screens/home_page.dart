import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';

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
  List<List<bool>> flipping = [], possibleMove = [];
  List<List<Function({bool operate})>> cellStateFns = [], flipStateFns = [];
  bool whiteTurn = true;

  @override
  void initState() {
    boardWidth = widget.screenWidth - 50;
    cellWidth = boardWidth / boardLength;
    cellStateFns.length = boardHeight;
    flipStateFns.length = boardHeight;
    flipping.length = boardHeight;
    possibleMove.length = boardHeight;
    for (int i = 0; i < boardHeight; i++) {
      cellStateFns[i] = [];
      cellStateFns[i].length = boardLength;
      flipStateFns[i] = [];
      flipStateFns[i].length = boardLength;
      flipping[i] = [];
      flipping[i].length = boardLength;
      possibleMove[i] = [];
      board.add([]);
      for (int j = 0; j < boardLength; j++) {
        board[i].add(-1);
        possibleMove[i].add(false);
      }
    }

    initBoard();
    super.initState();
  }

  Widget piece(int i, int j) => StatefulBuilder(
        builder: (context, setCellState) {
          Widget child = Container();
          if (possibleMove[i][j])
            child = Center(
              child: Container(
                width: cellWidth / 2,
                height: cellWidth / 2,
                decoration: BoxDecoration(
                  color: whiteTurn ? Colors.white54 : Colors.black54,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          if (board[i][j] == 0)
            child = FittedBox(
              fit: BoxFit.cover,
              child: Image.asset("assets/flip_0/frame_0.png"),
            );
          else if (board[i][j] == 2)
            child = FittedBox(
              fit: BoxFit.cover,
              child: Image.asset("assets/flip_0/frame_18.png"),
            );
          cellStateFns[i][j] = ({bool operate = true}) {
            setCellState(() {
              if (operate) board[i][j] = (board[i][j] + 1) % 4;
            });
          };
          return Container(
            padding: EdgeInsets.all(1),
            width: cellWidth,
            height: cellWidth,
            color: Colors.black,
            child: InkWell(
              onTap: () async {
                if (board[i][j] == -1 && possibleMove[i][j]) {
                  if (!whiteTurn) board[i][j] = 1;
                  whiteTurn = !whiteTurn;
                  cellStateFns[i][j]();
                  await _flipPieces(_getPiecesToFlip(i, j, board[i][j]));
                  _markPossibleMoves();
                  return;
                }
              },
              child: Container(
                color: Colors.green[600],
                child: child,
              ),
            ),
          );
        },
      );

  void initBoard() {
    board[3][3] = 0;
    board[4][4] = 0;
    board[3][4] = 2;
    board[4][3] = 2;

    WidgetsBinding.instance.addPostFrameCallback((_) => _markPossibleMoves());
  }

  @override
  Widget build(BuildContext context) {
    mainStack = [
      Column(
        children: List.generate(
            boardHeight,
            (i) => Row(
                  children: List.generate(boardLength, (j) => piece(i, j)),
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
    cellStateFns[i][j]();
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
      if (board[i][j] % 2 == 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        flipStateFns[i][j]();
        cellStateFns[i][j]();
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
    int value = whiteTurn ? 0 : 2;
    for (int i = 0; i < boardHeight; i++)
      for (int j = 0; j < boardLength; j++) {
        if (board[i][j] != -1) continue;
        bool setThisCellState = false;
        if (possibleMove[i][j]) {
          possibleMove[i][j] = false;
          setThisCellState = true;
        }
        if (_getPiecesToFlip(i, j, value).length > 0) {
          possibleMove[i][j] = true;
          setThisCellState = true;
        }
        if (setThisCellState) cellStateFns[i][j](operate: false);
      }
  }

  Future<void> _flipPieces(List<List<List<int>>> piecesToFlip) async {
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
              board[currentI][currentJ] % 2 == 1) {
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
