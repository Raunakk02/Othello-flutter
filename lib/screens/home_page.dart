import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:othello/components/flip_piece.dart';
import 'package:othello/components/piece.dart';
import 'package:othello/components/side_drawer.dart';
import 'package:othello/objects/game_info.dart';
import 'package:othello/objects/room_data.dart';
import 'package:othello/utils/globals.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home-page';
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
      drawer: SideDrawer(),
      body: ChangeNotifierProvider<RoomData>(
        create: (context) => _gameInfo.roomData,
        child: Padding(
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
              Expanded(
                child: Container(
                  child: ScoreBoard(aboveBoard: false, forWhite: false),
                ),
              ),
            ],
          ),
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
    this.forWhite = true,
    this.aboveBoard = true,
  }) : super(key: key);

  final bool forWhite;
  final bool aboveBoard;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: aboveBoard ? Alignment.bottomLeft : Alignment.topRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Container(
            color: Colors.brown.withAlpha(100),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage(
                      'assets/${forWhite ? 'flip_0' : 'flip_1'}/frame_0.png'),
                  width: Globals.screenWidth * 0.065,
                ),
                Icon(Icons.close_rounded),
                Consumer<RoomData>(
                  builder: (context, roomData, child) {
                    return Text(
                      roomData.totalPieces(forWhite: forWhite).toString(),
                      style: TextStyle(
                        fontSize: Globals.screenWidth * 0.055,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                SizedBox(width: Globals.screenWidth * 0.04),
                Icon(Icons.access_time),
                SizedBox(width: Globals.screenWidth * 0.02),
                ChanceTimer(forWhite),
              ],
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}

class ChanceTimer extends StatefulWidget {
  ChanceTimer(this.forWhite);

  final bool forWhite;

  @override
  _ChanceTimerState createState() => _ChanceTimerState();
}

class _ChanceTimerState extends State<ChanceTimer> {
  late DateTime _time;
  Timer? _timer;

  void toggleTimer() {
    if (Provider.of<RoomData>(context, listen: false).isWhiteTurn ==
        widget.forWhite)
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        continueTimer();
      });
    else
      cancelTimer();
  }

  void continueTimer() {
    if (_timer != null) return;
    const onSec = const Duration(seconds: 1);
    _timer = Timer.periodic(onSec, (Timer timer) {
      setState(() {
        _time = _time.add(onSec);
      });
    });
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    _time = DateTime(DateTime.now().year).add(
        Provider.of<RoomData>(context, listen: false)
            .getTotalDuration(widget.forWhite));
    Provider.of<RoomData>(context, listen: false).addListener(toggleTimer);
    toggleTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time.hour == 0
          ? DateFormat.ms().format(_time)
          : DateFormat.Hms().format(_time),
      style: GoogleFonts.montserrat(
        fontSize: Globals.screenWidth * 0.055,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
