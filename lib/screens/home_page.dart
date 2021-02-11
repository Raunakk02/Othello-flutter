import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<ImageSequenceAnimatorState>> imageSequenceAnimators = [];

  @override
  void initState() {
    imageSequenceAnimators.length = 8;
    for (int i = 0; i < 8; i++) {
      imageSequenceAnimators[i] = [];
      imageSequenceAnimators[i].length = 8;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Othello Game")),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: FittedBox(
            child: Column(
              children: List.generate(
                8,
                (i) => Row(
                  children: List.generate(
                    8,
                    (j) => FittedBox(
                      child: InkWell(
                        onTap: () {
                          imageSequenceAnimators[i][j].restart();
                        },
                        child: ImageSequenceAnimator(
                          "assets/flip_0",
                          "frame_",
                          0,
                          1,
                          "png",
                          19,
                          fps: 33,
                          onReadyToPlay: (state) =>
                              imageSequenceAnimators[i][j] = state,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
