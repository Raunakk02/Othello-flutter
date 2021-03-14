import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  Piece(this.cellWidth, {this.onCreation, this.initValue = -1, this.onTap});

  final Function(PieceState state)? onCreation;
  final Function(PieceState state)? onTap;
  final double cellWidth;
  final int initValue;

  @override
  PieceState createState() => PieceState(initValue);
}

class PieceState extends State<Piece> {
  PieceState(int value) : this._value = _valueFromBoardValue(value);

  int _value;
  bool possibleMove = false;

  static int _valueFromBoardValue(int boardValue) =>
      boardValue == 1 ? 2 : boardValue;

  int get boardValue {
    if (_value == 0 || _value == 3) return 0;
    if (_value == 1 || _value == 2) return 1;
    return -1;
  }

  int get value => _value;

  static bool whiteTurn = false;

  @override
  void initState() {
    (widget.onCreation ?? (_) {})(this);
    super.initState();
  }

  void stateFn({bool operate = true}) {
    setState(() {
      if (operate) _value = (_value + 1) % 4;
    });
  }

  void set(int boardValue) {
    setState(() {
      _value = _valueFromBoardValue(boardValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (possibleMove && value == -1)
      child = Center(
        child: Container(
          width: widget.cellWidth / 2,
          height: widget.cellWidth / 2,
          decoration: BoxDecoration(
            color: whiteTurn ? Colors.white54 : Colors.black54,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      );
    if (_value == 0)
      child = FittedBox(
        fit: BoxFit.cover,
        child: Image.asset("assets/flip_0/frame_0.png"),
      );
    else if (_value == 2)
      child = FittedBox(
        fit: BoxFit.cover,
        child: Image.asset("assets/flip_0/frame_18.png"),
      );
    return Container(
      padding: const EdgeInsets.all(0.5),
      width: widget.cellWidth,
      height: widget.cellWidth,
      color: Colors.black,
      child: InkWell(
        onTap: () {
          if (_value == -1 && possibleMove) {
            if (!whiteTurn) _value = 1;
            stateFn();
            (widget.onTap ?? () {})(this);
          }
        },
        child: Container(
          color: Colors.green[600],
          child: child,
        ),
      ),
    );
  }
}
