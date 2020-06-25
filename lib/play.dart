import 'package:flutter/material.dart';

class PlayView extends StatefulWidget {
  PlayView({Key key, this.title, this.words}) : super(key: key);

  final String title;
  final List<String> words;

  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  int currentWord;

  void initState() {
    currentWord = 0;
    super.initState();
  }

  Widget playCard() {
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
                elevation: 5,
                child: Center(
                  child: Text(
                    widget.words[currentWord],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: playCard());
  }
}
