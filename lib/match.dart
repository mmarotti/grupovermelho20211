import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main menu widget, responsible for rendering new game options

class Match extends StatefulWidget {
  Match({Key? key, required this.matchReference}) : super(key: key);

  final DocumentReference matchReference;

  @override
  _MatchState createState() => _MatchState();
}

class _MatchState extends State<Match> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match'),
      ),
      body: Center(
        child: StreamBuilder(
            stream: widget.matchReference.snapshots(),
            builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('Loading...'),
                );
              } else {
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else if (snapshot.data?['player_2'] == null)
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Match ID: ${widget.matchReference.id}'),
                      Text('Waiting for second player...')
                    ],
                  );
                else
                  return Text('Player found');
              }
            }),
      ),
    );
  }
}
