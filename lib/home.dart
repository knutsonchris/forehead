import 'package:flutter/material.dart';
import 'play.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'package:flutter/cupertino.dart';

// TODO: this is a super sloppy way to do things, would be nice to put this somewhere else
Map<String, List<String>> decks = {
// this is also super hacky, our deck card widget will key off of the "create new" string and open up an add new deck dialog instead of starting a game
  "create new": [],
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
    // TODO: this isn't needed here anymore since we load the decks with a FutureBuilder
    loadDecks();
  }

  // loadDecks will grab word lists shipped as assets and slam them into that messy decks map
  Future<void> loadDecks() async {
    String threek = await rootBundle.loadString('assets/words/3k.txt');
    String four66k = await rootBundle.loadString('assets/words/466k.txt');
    String sevenk = await rootBundle.loadString('assets/words/7k.txt');
    String tenk = await rootBundle.loadString('assets/words/10k.txt');
    String animals = await rootBundle.loadString('assets/words/animals.txt');
    String animals2 = await rootBundle.loadString('assets/words/animals2.txt');
    String easy = await rootBundle.loadString('assets/words/easy.txt');
    String medium = await rootBundle.loadString('assets/words/medium.txt');
    String hard = await rootBundle.loadString('assets/words/hard.txt');
    String objects = await rootBundle.loadString('assets/words/objects.txt');
    String persons = await rootBundle.loadString('assets/words/persons.txt');
    String verbs = await rootBundle.loadString('assets/words/verbs.txt');

    // split the new line delimited strings into lists
    decks["3k"] = threek.split("\n");
    decks["466k"] = four66k.split("\n");
    decks['7k'] = sevenk.split("\n");
    decks['10k'] = tenk.split("\n");
    decks['animals'] = animals.split("\n");
    decks['animals 2'] = animals2.split("\n");
    decks['easy'] = easy.split("\n");
    decks['medium'] = medium.split("\n");
    decks['hard'] = hard.split("\n");
    decks['objects'] = objects.split("\n");
    decks['persons'] = persons.split("\n");
    decks['verbs'] = verbs.split("\n");
  }

  // this audio player allows us to play a sound without holding up execution of our single thread
  Future<AudioPlayer> startSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("start.mp3");
  }

  // this widget defines the actions and appearance of each card in our deck
  Widget deckCard(int index) {
    String deckName = decks.keys.toList()[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        // it really would be nice to come up with a better solution for this, but ya know, deadline development
        if (deckName == "create new") {
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
          // lol this else was originally the only functionality of each deck card, but hey gotta do what ya gotta do
          startSound();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    // bring up a new PlayView with the desired deck
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

  //deckGrid will make a deckCard for each item in our decks map
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
    // this future builder will run the loadDecks function and wait for it to finish grabbing the word lists off thee disk before rendering  the cards
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
