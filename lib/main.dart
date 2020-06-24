import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'forehead',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Map<String, List<String>> decks = {
  "cars": ["lambo", "F150"],
  "sports": ["soccer", "volleyball"],
  "animals": ["cat", "dog"],
  "drinks": ["coffee", "tea"],
  "colors": ["black", "white"],
  "emotions": ["happy", "sad"],
  "shoes": ["flip flop", "tennis shoe"],
};

class _MyHomePageState extends State<MyHomePage> {
  Widget deckCard(int index) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: double.maxFinite,
        width: double.maxFinite,
        child: Card(
          elevation: 5,
          child: Center(
            child: Text(
              decks.keys.toList()[index],
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ));
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
    return Scaffold(backgroundColor: Colors.blue[300], body: deckGrid());
  }
}
