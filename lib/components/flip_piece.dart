import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:othello/components/piece.dart';

class FlipPiece extends StatefulWidget {
  FlipPiece(this.cellWidth, this.i, this.j,
      {this.onCreation, @required this.getPieceStateFn});

  final double cellWidth;
  final int i;
  final int j;
  final Function(FlipPieceState state) onCreation;
  final PieceState Function() getPieceStateFn;

  @override
  FlipPieceState createState() => FlipPieceState();
}

class FlipPieceState extends State<FlipPiece> {
  bool flipping = false;

  void flip() {
    _flipStateFn();
    _pieceState.stateFn();
  }

  @override
  void initState() {
    (widget.onCreation ?? (_) {})(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.cellWidth * widget.j,
      top: widget.cellWidth * widget.i -
          (((widget.cellWidth * (90 / 74)) - widget.cellWidth) / 2),
      child: IgnorePointer(
        child: flipping ? _flipAnimation() : Container(),
      ),
    );
  }

  Widget _flipAnimation() {
    final _onFinishPlaying = (state) {
      if (_pieceState.value % 2 == 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _flipStateFn();
        _pieceState.stateFn();
      });
    };
    return Container(
      width: widget.cellWidth,
      height: widget.cellWidth * (90 / 74),
      child: FittedBox(
        child: InkWell(
          child: ImageSequenceAnimator(
            _pieceState.boardValue == 1 ? "assets/flip_0" : 'assets/flip_1',
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

  void _flipStateFn({operate = true}) {
    if (operate) flipping = !flipping;
    setState(() {});
  }

  PieceState get _pieceState => widget.getPieceStateFn();
}
