import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'match.dart';

// Main menu widget, responsible for rendering new game options

class MainMenu extends StatefulWidget {
  MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference _matchesCollection =
        database.collection('matches');

    return Scaffold(
      appBar: AppBar(
        title: Text('Main menu'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final matchReference = await _matchesCollection
                    .add({"player_1": "123123", "player_2": null});

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Match(matchReference: matchReference)),
                );
              },
              child: const Text('New game'),
            ),
          ],
        ),
      ),
    );
  }
}
