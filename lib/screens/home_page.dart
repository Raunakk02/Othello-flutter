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
  double boardWidth;
  double cellWidth;
  List<Widget> mainStack;
  List<List<int>> board = [];
  List<List<Function>> cellStateFns = [];
  bool whiteTurn = true;

  @override
  void initState() {
    boardWidth = widget.screenWidth - 50;
    cellWidth = boardWidth / 8;
    cellStateFns.length = 8;
    for (int i = 0; i < 8; i++) {
      cellStateFns[i] = [];
      cellStateFns[i].length = 8;
      board.add([]);
      for (int j = 0; j < 8; j++) board[i].add(-1);
    }

    initBoard();

    mainStack = [
      Column(
        children: List.generate(
            8,
            (i) => Row(
                  children: List.generate(
                      8,
                      (j) => StatefulBuilder(
                            builder: (context, setCellState) {
                              Widget child = Container();
                              if (board[i][j] == 0)
                                child = FittedBox(
                                  fit: BoxFit.cover,
                                  child:
                                      Image.asset("assets/flip_0/frame_0.png"),
                                );
                              else if (board[i][j] == 2)
                                child = FittedBox(
                                  fit: BoxFit.cover,
                                  child:
                                      Image.asset("assets/flip_0/frame_18.png"),
                                );
                              cellStateFns[i][j] = () {
                                setCellState(() {
                                  board[i][j] = (board[i][j] + 1) % 4;
                                });
                              };
                              return Container(
                                padding: EdgeInsets.all(1),
                                width: cellWidth,
                                height: cellWidth,
                                color: Colors.black,
                                child: InkWell(
                                  onTap: () async {
                                    if (board[i][j] == -1) {
                                      if (!whiteTurn) board[i][j] = 1;
                                      whiteTurn = !whiteTurn;
                                      cellStateFns[i][j]();
                                      return;
                                    }
                                    _flip(i, j);
                                  },
                                  child: Container(
                                    color: Colors.green[600],
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          )),
                )),
      ),
    ];
    super.initState();
  }

  void initBoard() {
    board[3][3] = 0;
    board[4][4] = 0;
    board[3][4] = 2;
    board[4][3] = 2;
  }

  @override
  Widget build(BuildContext context) {
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
    mainStack.add(piece(i, j));
    cellStateFns[i][j]();
    setState(() {});
  }

  Widget piece(int i, int j) {
    final _onFinishPlaying = (state) {
      if (board[i][j] % 2 == 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          mainStack.length = 1;
        });
        cellStateFns[i][j]();
      });
    };
    return Positioned(
      left: cellWidth * j,
      top: cellWidth * i - (((cellWidth * (90 / 74)) - cellWidth) / 2),
      child: Container(
        width: cellWidth,
        height: cellWidth * (90 / 74),
        child: FittedBox(
          child: InkWell(
              child: ImageSequenceAnimator(
            board[i][j] == 0 ? "assets/flip_0" : 'assets/flip_1',
            "frame_",
            0,
            1,
            "png",
            19,
            fps: 50,
            waitUntilCacheIsComplete: true,
            onFinishPlaying: _onFinishPlaying,
          )),
        ),
      ),
    );
  }
}
