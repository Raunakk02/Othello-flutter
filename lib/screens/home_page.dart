import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:othello/components/piece.dart';

class HomePage extends StatefulWidget {
  HomePage(this.screenWidth);

  final double screenWidth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double boardWidth;
  double cellWidth;

  @override
  void initState() {
    boardWidth = widget.screenWidth - 50;
    cellWidth = boardWidth / 8;
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
            padding: const EdgeInsets.all(9),
            child: Container(
              padding: const EdgeInsets.all(1),
              color: Colors.black,
              child: Container(
                color: Colors.green[700],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      8,
                          (i) => Row(
                        children: List.generate(
                            8,
                                (j) => Piece(cellWidth)),
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
