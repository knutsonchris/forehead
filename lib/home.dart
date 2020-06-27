import 'package:flutter/material.dart';
import 'play.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';

Map<String, List<String>> decks = {
  "cars": ["lambo", "F150"],
  "sports": ["soccer", "volleyball"],
  "animals": ["cat", "dog"],
  "drinks": ["coffee", "tea"],
  "colors": ["black", "white"],
  "emotions": ["happy", "sad"],
  "shoes": ["flip flop", "tennis shoe"],
};

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    loadDecks();
  }

  Future<void> loadDecks() async {
    String threek = await rootBundle.loadString('assets/words/3k.txt');
    String four66k = await rootBundle.loadString('assets/words/466k.txt');
    decks["3k"] = threek.split("\n");
    decks["466k"] = four66k.split("\n");
    decks["create new"] = [];
  }

  Future<AudioPlayer> startSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("start.mp3");
  }

  Widget deckCard(int index) {
    String deckName = decks.keys.toList()[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        if (deckName == "create new") {
          print("new");
          Navigator.of(context).push(new MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                final deckNameController = TextEditingController();
                final textController = TextEditingController();

                return Scaffold(
                  appBar: AppBar(
                    iconTheme: IconThemeData(color: Colors.black),
                    backgroundColor: Colors.white,
                    title: Text(
                      "new deck",
                      style: GoogleFonts.ubuntu(color: Colors.black),
                    ),
                  ),
                  body: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding:
                              EdgeInsets.only(top: 30, left: 30, right: 30),
                          child: Text(
                            "enter a deck name",
                            style: GoogleFonts.ubuntu(
                                color: Colors.black, fontSize: 30),
                          )),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 30),
                        child: TextField(
                          controller: deckNameController,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            "enter a list of words\neach on a new line",
                            style: GoogleFonts.ubuntu(
                                color: Colors.black, fontSize: 30),
                            textAlign: TextAlign.center,
                          )),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 30),
                        child: TextField(
                          controller: textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: CupertinoButton(
                            onPressed: () {
                              setState(() {
                                decks[deckNameController.text] =
                                    textController.text.split("\n");

                                Navigator.of(context).pop();
                              });
                            },
                            color: CupertinoColors.activeBlue,
                            child: Text(
                              "save",
                              style: GoogleFonts.ubuntu(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              fullscreenDialog: true));
        } else {
          startSound();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PlayView(title: deckName, words: decks[deckName])),
          );
        }
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          height: double.maxFinite,
          width: double.maxFinite,
          child: Card(
            elevation: 5,
            child: Center(
              child: Text(
                decks.keys.toList()[index],
                style: GoogleFonts.ubuntu(fontSize: 30),
              ),
            ),
          )),
    );
  }

  Widget deckGrid() {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 2,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(decks.length, (index) {
        return Center(child: deckCard(index));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadDecks(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.none &&
            snap.hasData == null) {
          return Center(
            child: Text("loading"),
          );
        }
        return Scaffold(backgroundColor: Colors.black, body: deckGrid());
      },
    );
  }
}
