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

class _HomePageState extends State<HomePage> {
  double boardWidth;
  double cellWidth;
  List<Widget> mainStack;
  List<List<int>> board = [];
  int eraseI, eraseJ;

  @override
  void initState() {
    boardWidth = widget.screenWidth - 50;
    cellWidth = boardWidth / 8;
    for (int i = 0; i < 8; i++) {
      board.add([]);
      for (int j = 0; j < 8; j++) board[i].add(0);
    }

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
                              Function callStateFn = () {
                                setCellState(() {
                                  board[i][j] = (board[i][j] + 1) % 4;
                                  print(board[i][j]);
                                });
                              };
                              return Container(
                                padding: EdgeInsets.all(1),
                                width: cellWidth,
                                height: cellWidth,
                                color: Colors.black,
                                child: InkWell(
                                  onTap: () {
                                    mainStack.add(piece(i, j, callStateFn));
                                    print("calling to erase bg");
                                    callStateFn();
                                    setState(() {});
                                  },
                                  child: Container(
                                    color: Colors.green,
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
              color: Colors.green[700],
              child: Stack(
                children: mainStack,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget piece(int i, int j, Function callStateFunction) {
    final _onFinishPlaying = (state) {
      if (board[i][j] % 2 == 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        callStateFunction();
        setState(() {
          mainStack.removeLast();
        });
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
            child: board[i][j] == 0
                ? ImageSequenceAnimator(
                    "assets/flip_0",
                    "frame_",
                    0,
                    1,
                    "png",
                    19,
                    fps: 33,
                    onFinishPlaying: _onFinishPlaying,
                  )
                : ImageSequenceAnimator(
                    "assets/flip_1",
                    "frame_",
                    0,
                    1,
                    "png",
                    19,
                    fps: 33,
                    onFinishPlaying: _onFinishPlaying,
                  ),
          ),
        ),
      ),
    );
  }
}
