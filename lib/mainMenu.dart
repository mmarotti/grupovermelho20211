import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main menu widget, responsible for rendering new game options

class MainMenu extends StatefulWidget {
  MainMenu({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference _gamesCollection = database.collection('matches');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _gamesCollection.add({"player_1": "123123"});
              },
              child: const Text('New game'),
            ),
          ],
        ),
      ),
    );
  }
}
