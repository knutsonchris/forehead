import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayView extends StatefulWidget {
  PlayView({Key key, this.title, this.words}) : super(key: key);

  final String title;
  final List<String> words;

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  // not really sure if this is necessary to first define then populate the variables
  // but i saw a guy who was smarter than me doing it once so like any smart dev i copied them
  // currentWord is the word that will be shown in the card
  int currentWord;
  // timeLeft will act as our timer
  int timeLeft;
  // playerReady will indicate when the user has put the device up to their head
  bool playerReady;
  // gameOver will indicate when either there are no more cards in the deck or the time has run out
  bool gameOver;
  // gameOverReason will be populated with  text as to why the game ended, for example when the time runs out
  String gameOverReason;
  // countdown is a poorly named variable for the 3 second countdown in the  beginning
  int countdown;
  // _accelerometer will allow us to continually monitor the values coming from the accelerometer
  StreamSubscription<AccelerometerEvent> _accelerometer;
  double yAxis;
  double zAxis;
  // results will keep track of which words the user was able guess and which they passed, LinkedHashMap to preserve order
  LinkedHashMap<String, bool> results;
  // currentWidget allows us to swap out the card being displayed with a new one with updated content
  Widget currentWidget;

  void initState() {
    playerReady = false;
    countdown = 3;
    gameOver = false;
    currentWord = 0;
    timeLeft = 60;
    results = new LinkedHashMap<String, bool>();
    _accelerometer = accelerometerEvents.listen((AccelerometerEvent event) {
      yAxis = event.y;
      zAxis = event.z;
    });

    // at this point in the execution, there is no context. we can't use any text themes so just use some dummy widget until the rest of the jazz loads
    currentWidget = Text(";)");
    // kick off our two control loops
    gameController();
    timeController();
    widget.words.shuffle();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _accelerometer.cancel();
  }

  // bunch of audio players to play sounds ;D
  correctSound() async {
    AudioPlayer player = new AudioPlayer();
    return await player.play(AssetSource("correct.mp3"));
  }

  scoreSound() async {
    AudioPlayer player = new AudioPlayer();
    return await player.play(AssetSource("score.mp3"));
  }

  endSound() async {
    AudioPlayer player = new AudioPlayer();
    return await player.play(AssetSource("end.mp3"));
  }

  tickSound() async {
    AudioPlayer player = new AudioPlayer();
    return await player.play(AssetSource("tick.mp3"));
  }

  passSound() async {
    AudioPlayer player = new AudioPlayer();
    return await player.play(AssetSource("pass.mp3"));
  }

  // this does two functions equally awkwardly
  // will give us a countdown and end game play when the timer runs out
  Future<void> timeController() async {
    while (countdown > 0) {
      await Future.delayed(Duration(milliseconds: 200));
      continue;
    }
    // if the game is ended by the game controller before the time runs out, don't bother keeping track of the time
    while (timeLeft != 0 && !gameOver) {
      await Future.delayed(Duration(seconds: 1));
      if (timeLeft <= 10) {
        tickSound();
      }
      setState(() {
        timeLeft--;
      });
    }
    if (timeLeft == 0) {
      gameOverReason = "time is up!";
    }

    endSound();
    HapticFeedback.vibrate();
    setState(() {
      gameOver = true;
      currentWidget = playCard(gameOverReason, Colors.red, false);
    });

    await Future.delayed(Duration(seconds: 3));

    // this feels awkward to shove here but it is the easiest
    scoreSound();
    HapticFeedback.heavyImpact();
    // show the user their results in a bottom modal, return to previous screen when they are done looking
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          int numberCorrect = 0;
          results.forEach((key, value) {
            if (value) numberCorrect++;
          });
          return new Container(
              height: 750.0,
              color: Colors.black, //could change this to Color(0xFF737373),
              //so you don't have to change MaterialApp canvasColor
              child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.blue,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            "score: $numberCorrect",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                                fontSize: 90, color: Colors.white),
                          ),
                        )),
                    new ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.only(top: 30),
                        itemCount: results.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          String theWord = results.keys.toList()[index];
                          return wordResult(theWord, results[theWord]);
                        }),
                  ],
                ),
              ));
        });

    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
  }

  // game controller will do it's best to iterate through the words in the deck, keeping track of successful and unsuccessful guesses
  Future<void> gameController() async {
    print("gameController start");
    while (true) {
      // if the game is ended before the end of the deck, quit the game controller
      if (gameOver) {
        return;
      }
      // add a delay or our poor single thread will get choked out lol
      await Future.delayed(Duration(milliseconds: 100));
      print("yAxis: $yAxis");
      print("zAxis: $zAxis");

      // Needed in case the accelerometer is not ready yet
      if (yAxis == null || zAxis == null) {
        continue;
      }

      // wait until the player tilts the phone on its side (on their forehead)
      if (!playerReady) {
        if ((yAxis <= 4 && yAxis >= -4) && (zAxis <= 4 && zAxis >= -4)) {
          playerReady = true;
        }
        continue;
      }

      // countdown from 3, playing a sound
      while (countdown > 0) {
        tickSound();
        setState(() {
          currentWidget = playCard(countdown.toString(), Colors.blue, false);
        });

        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(seconds: 1));
        countdown--;
      }

      // display the current word on the card and wait for a tilt
      // TODO: find a way to only run this once
      setState(() {
        gameOver
            ? {}
            : currentWidget =
                playCard(widget.words[currentWord], Colors.blue, true);
      });

      // a successful guess
      if (zAxis < -9) {
        correctSound();
        HapticFeedback.heavyImpact();
        // add a success to our results
        results[widget.words[currentWord]] = true;
        // wait until they tilt the phone back onto their forehead
        setState(() {
          gameOver
              ? {}
              : currentWidget = playCard("correct!", Colors.green, false);
        });
        while (zAxis < -2) {
          await Future.delayed(Duration(milliseconds: 500));
        }
        HapticFeedback.heavyImpact();

        // increment the word count and check if we have hit the end of the deck
        currentWord++;
        if (currentWord == widget.words.length) {
          // exit the loop
          // TODO: display number of correct and incorrect
          break;
        } else {
          // restart the loop
          continue;
        }
      }

      // a pass
      if (zAxis > 9) {
        // player has tilted phone backwards, a pass
        passSound();
        HapticFeedback.heavyImpact();
        // add a pass to our results
        results[widget.words[currentWord]] = false;
        // wait until they tilt the phone back onto their foreheadR
        setState(() {
          gameOver
              ? {}
              : currentWidget =
                  playCard("pass!", Colors.deepOrangeAccent, false);
        });
        while (zAxis > 2) {
          await Future.delayed(Duration(milliseconds: 500));
        }
        HapticFeedback.heavyImpact();

        // increment the word count and check if we have hit the end of the deck
        currentWord++;
        if (currentWord == widget.words.length) {
          // exit the loop
          // TODO: display number of correct and incorrect
          break;
        } else {
          // restart the loop
          continue;
        }
      }
    }
    setState(() {
      gameOver = true;
      gameOverReason = "no more words!";
    });
  }

  // defines the appearance and behaviour of the main play card widget
  Widget playCard(String word, Color color, bool showTimer) {
    // use a Stack here so we can put the back button on top of the play card
    return Stack(
      children: [
        // position the back button in the top right corner, which when rotated, becomes the top left...
        Positioned(
          right: 0,
          top: 0,
          child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("tapped the 'go back' button'");
              },
              child: RotatedBox(quarterTurns: 1, child: Text("go back"))),
        ),
        RotatedBox(
            quarterTurns: 1,
            child: Container(
                padding: EdgeInsets.fromLTRB(60, 30, 60, 30),
                height: double.maxFinite,
                width: double.maxFinite,
                child: Card(
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 10.0,
                    ),
                  ),
                  color: color,
                  elevation: 5,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(word,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                                fontSize: 90, color: Colors.white)),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Text(
                              showTimer ? timeLeft.toString() : "",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 70, color: Colors.white),
                            )),
                      )
                    ],
                  ),
                ))),
      ],
    );
  }

  // each word on the result page will have it's own appearance depending on if the user guessed it correctly
  Widget wordResult(String word, bool success) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          word,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
              fontSize: 50, color: success ? Colors.white : Colors.blueGrey),
        ),
        Icon(
          success ? Icons.check_circle : Icons.cancel,
          color: success ? Colors.green : Colors.blueGrey,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // we need to wait until the context is initialized to set currentWidget
    // this is because we use a text style on the playCard
    if (!playerReady) {
      currentWidget = playCard("place on forehead", Colors.blue, false);
    }
    return SafeArea(
        child: Scaffold(backgroundColor: Colors.black, body: currentWidget));
  }
}
