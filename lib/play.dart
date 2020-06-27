import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayView extends StatefulWidget {
  PlayView({Key key, this.title, this.words}) : super(key: key);

  final String title;
  final List<String> words;

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  int currentWord;
  int timeLeft;
  bool playerReady;
  bool gameOver;
  String gameOverReason;
  int countdown;
  StreamSubscription<AccelerometerEvent> _accelerometer;
  double yAxis;
  double zAxis;
  LinkedHashMap<String, bool> results;

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

    currentWidget = Text(";)");
    gameController();
    timeController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _accelerometer.cancel();
  }

  Future<AudioPlayer> correctSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("correct.mp3");
  }

  Future<AudioPlayer> scoreSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("score.mp3");
  }

  Future<AudioPlayer> endSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("end.mp3");
  }

  Future<AudioPlayer> tickSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("tick.mp3");
  }

  Future<AudioPlayer> passSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("pass.mp3");
  }

  Future<void> timeController() async {
    while (countdown > 0) {
      await Future.delayed(Duration(milliseconds: 200));
      continue;
    }
    while (timeLeft != 0 && !gameOver) {
      await Future.delayed(Duration(seconds: 1));
      if (timeLeft <= 10){
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

    scoreSound();
    HapticFeedback.heavyImpact();
    await showModalBottomSheet(
        // isScrollControlled: true,
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "score: $numberCorrect",
                        style: GoogleFonts.ubuntu(
                            fontSize: 90, color: Colors.white),
                      ),
                    ),
                    new ListView.builder(
                        shrinkWrap: true,
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

  Widget playCard(String word, Color color, bool showTimer) {
    return GestureDetector(
      onTap: () {
        if (currentWord == widget.words.length - 1) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            currentWord++;
          });
        }
      },
      child: RotatedBox(
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
    );
  }

  Widget wordResult(String word, bool success) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          word,
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
    return Scaffold(backgroundColor: Colors.black, body: currentWidget);
  }
}
