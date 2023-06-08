import 'package:flutter/material.dart';
import 'deck.dart';
import 'play.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Deck> _decks = [];

  Future<void> _loadDecks() async {
    print("loading decks");
    _decks = await loadDecks();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveNewDeck(String deckName, List<String> deckWords) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File savedDecks = File('$path/decks.json');
    Map<String, List<String>> goodies = await loadSavedDecks();
    goodies[deckName] = deckWords;
    String jsonDecks = json.encode(goodies);
    savedDecks.writeAsStringSync(jsonDecks);
  }

  // this audio player allows us to play a sound without holding up execution of our single thread
  startSound() async {
    AudioPlayer player = new AudioPlayer();
    return player.play(AssetSource("start.mp3"));
  }

  // this widget defines the actions and appearance of each card in our deck
  Widget deckCard(Deck d) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        // it really would be nice to come up with a better solution for this, but ya know, deadline development
        if (d.name == "create new") {
          // this sloppily pulls up a full screen window from which we can add a new deck
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
                  body: ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                          padding:
                              EdgeInsets.only(top: 30, left: 30, right: 30),
                          child: Text(
                            "enter a deck name",
                            style: GoogleFonts.ubuntu(
                                color: Colors.black, fontSize: 30),
                            textAlign: TextAlign.center,
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
                                // grab the text from our TextEditingControllers and slam it into our sloppy map
                                d.words = textController.text.split("\n");
                                Navigator.of(context).pop();
                              });
                              // slam the new deck into our saved decks json
                              saveNewDeck(deckNameController.text,
                                  textController.text.split("\n"));
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
          // lol this else was originally the only functionality of each deck card, but hey gotta do what ya gotta do
          startSound();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    // bring up a new PlayView with the desired deck
                    PlayView(title: d.name, words: d.words)),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: double.maxFinite,
        width: double.maxFinite,
        child: Card(
          elevation: 5,
          child: Image.asset(d.imagepath), //decksImages[deckName],
        ),
      ),
    );
  }

  //deckGrid will make a deckCard for each item in our decks map
  Widget deckGrid() {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 2,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(_decks.length, (index) {
        return Center(child: deckCard(_decks[index]));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // this future builder will run the loadDecks function and wait for it to finish grabbing the word lists off thee disk before rendering  the cards
    return FutureBuilder(
      future: _loadDecks(),
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
