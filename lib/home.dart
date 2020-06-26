import 'package:flutter/material.dart';
import 'play.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
  Widget deckCard(int index) {
    String deckName = decks.keys.toList()[index];
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PlayView(title: deckName, words: decks[deckName])),
        );
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
    return Scaffold(backgroundColor: Colors.black, body: deckGrid());
  }
}
