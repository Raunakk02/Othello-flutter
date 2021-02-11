import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';

class Piece extends StatefulWidget {
  Piece(this.cellWidth);

  final double cellWidth;

  @override
  _PieceState createState() => _PieceState();
}

class _PieceState extends State<Piece> {
  int value = 0;

  void callStateFn() {
    setState(() {
      value = (value + 1) % 4;
      print(value);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (value == 0)
      child = FittedBox(
        fit: BoxFit.cover,
        child:
        Image.asset("assets/flip_0/frame_0.png"),
      );
    else if (value == 2)
      child = FittedBox(
        fit: BoxFit.cover,
        child:
        Image.asset("assets/flip_0/frame_18.png"),
      );
    else child = piece();
    return Container(
      padding: const EdgeInsets.all(1),
      width: widget.cellWidth,
      height: widget.cellWidth,
      color: Colors.black,
      child: InkWell(
        onTap: () {
          print("calling to erase bg");
          callStateFn();
        },
        child: Container(
          color: Colors.green,
          child: child,
        ),
      ),
    );
  }

  Widget piece() {
    final _onFinishPlaying = (state) {
      if (value % 2 == 0) return;
      callStateFn();
    };
    return value == 1
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
    );
  }
}
