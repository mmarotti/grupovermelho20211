import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'match.dart';

// Main menu widget, responsible for rendering new game options

class MainMenu extends StatefulWidget {
  MainMenu({Key? key, required this.playerReference}) : super(key: key);

  final DocumentReference playerReference;

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
        child: StreamBuilder(
            stream: widget.playerReference.snapshots(),
            builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('Loading...'),
                );
              } else {
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Player ID: ${widget.playerReference.id}'),
                      ElevatedButton(
                        onPressed: () async {
                          final matchReference = await _matchesCollection.add({
                            "player_1": widget.playerReference.id,
                            "player_2": null
                          });

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Match(matchReference: matchReference)),
                          );
                        },
                        child: const Text('New match'),
                      ),
                    ],
                  );
              }
            }),
      ),
    );
  }
}
