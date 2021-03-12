import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:othello/components/flip_piece.dart';
import 'package:othello/components/piece.dart';
import 'package:othello/objects/game_info.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/utils/globals.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _gameInfo = GameInfo(RoomData.offlinePvPNewGame(8, 8));
  late List<Widget> mainStack;

  @override
  void initState() {
    _initStack();
    print('Firebase Auth User Test : ${FirebaseAuth.instance.currentUser}');
    super.initState();
  }

  void _initStack() {
    mainStack = [
      Column(
        children: List.generate(
            _gameInfo.boardHeight,
            (i) => Row(
                  children: List.generate(
                      _gameInfo.boardLength,
                      (j) => Piece(
                            _gameInfo.cellWidth,
                            initValue: _gameInfo.board[i][j],
                            onCreation: (state) =>
                                _gameInfo.pieceStates[i][j] = state,
                            onTap: _gameInfo.onTapOnPiece(i, j, context),
                          )),
                )),
      ),
    ];

    for (int i = 0; i < _gameInfo.boardHeight; i++)
      for (int j = 0; j < _gameInfo.boardLength; j++)
        mainStack.add(
          FlipPiece(
            _gameInfo.cellWidth,
            i,
            j,
            onCreation: (state) => _gameInfo.flipPieceStates[i][j] = state,
            getPieceStateFn: () => _gameInfo.pieceStates[i][j]!,
          ),
        );
  }

  // TODO: add total duration and total pieces score board
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Othello Game"),
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: ScoreBoard(),
              ),
            ),
            Container(
              color: Colors.brown,
              padding: const EdgeInsets.all(10),
              child: Container(
                width: _gameInfo.cellWidth * _gameInfo.boardLength,
                height: _gameInfo.cellWidth * _gameInfo.boardHeight,
                color: Colors.green[600],
                child: Stack(
                  children: mainStack,
                ),
              ),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.undo),
        onPressed: _gameInfo.undo,
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.brown.withAlpha(100),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage('assets/flip_0/frame_0.png'),
                    width: Globals.screenWidth * 0.065,
                  ),
                  Icon(Icons.close_rounded),
                  Text(
                    '4',
                    style: TextStyle(
                      fontSize: Globals.screenWidth * 0.055,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: Globals.screenWidth * 0.04),
                  Icon(Icons.access_time),
                  SizedBox(width: Globals.screenWidth * 0.02),
                  Text('02:24', style: GoogleFonts.montserrat(
                    fontSize: Globals.screenWidth * 0.055,
                    fontWeight: FontWeight.w400,
                  )),
                ],
              ),
            ),
            SizedBox(height: 10)
          ],
        ));
  }
}
