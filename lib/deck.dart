import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Map<String, List<String>>> loadSavedDecks() async {
  Map<String, List<String>> thegoodies = {};
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    File savedDecks = File('$path/decks.json');
    String contents = savedDecks.readAsStringSync();
    final parsed = json.decode(contents);
    parsed.forEach((key, value) {
      List<dynamic> dlist = value;
      List<String> stringies = dlist.map((s) => s as String).toList();
      thegoodies[key] = stringies;
    });
  } catch (e) {
    print("could not load decks:" + e);
  }
  return thegoodies;
}

// loadDecks will grab word lists shipped as assets and slam them into that messy decks map

Future<List<Deck>> loadDecks() async {
  List<Deck> decks = [];
  decks.add(Deck(
      name: "3k",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/3k.txt"));

  decks.add(Deck(
      name: "466k",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/466k.txt"));

  decks.add(Deck(
      name: "7k",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/7k.txt"));

  decks.add(Deck(
      name: "10k",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/10k.txt"));

  decks.add(Deck(
      name: "animals",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/animals.txt"));

  decks.add(Deck(
      name: "animals2",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/animals2.txt"));

  decks.add(Deck(
      name: "easy",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/easy.txt"));

  decks.add(Deck(
      name: "medium",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/medium.txt"));

  decks.add(Deck(
      name: "hard",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/hard.txt"));

  decks.add(Deck(
      name: "objects",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/objects.txt"));

  decks.add(Deck(
      name: "persons",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/persons.txt"));

  decks.add(Deck(
      name: "verbs",
      imagepath: "assets/images/3x/tiger.jpeg",
      wordspath: "assets/words/verbs.txt"));

  for (Deck d in decks) {
    print("loading ${d.name}");
    await d.load();
  }

  return decks;
}

class Deck {
  String name;
  String imagepath;
  String wordspath;
  List<String> words;

  Deck(
      {@required this.name,
      @required this.imagepath,
      this.words = const [],
      @required this.wordspath});

  Future<void> load() async {
    print("loading ${this.wordspath}");
    print("imagepath ${this.imagepath}");
    String fileContents = await rootBundle.loadString(this.wordspath);
    this.words = fileContents.split("\n");
  }
}
