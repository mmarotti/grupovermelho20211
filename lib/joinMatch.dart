import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'styles/text.dart';

import 'match.dart';

// Join match widget, responsible for searching for an existant game

class JoinMatch extends StatefulWidget {
  JoinMatch({Key? key, required this.playerReference}) : super(key: key);

  final DocumentReference playerReference;

  @override
  _JoinMatchState createState() => _JoinMatchState();
}

class _JoinMatchState extends State<JoinMatch> {
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
                  child: Text('Loading...', style: secondaryTextStyle),
                );
              } else {
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}',
                      style: secondaryTextStyle);
                else
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        'Enter match ID',
                        style: primaryTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(onSubmitted: (String value) async {
                          final matchSnapshot =
                              await _matchesCollection.doc(value).get();

                          print(matchSnapshot.exists);

                          if (!matchSnapshot.exists) {
                            await showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Match not found!'),
                                  content: Text(
                                      'We couldn\'t find a match with the specified identifier'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            await matchSnapshot.reference
                                .update({"player_2": widget.playerReference.id})
                                .then((value) async => await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Match(
                                              playerReference:
                                                  widget.playerReference,
                                              matchReference:
                                                  matchSnapshot.reference)),
                                    ))
                                .catchError((value) async =>
                                    await showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Cannot join match!'),
                                          content: Text(
                                              'You don\'t have permission to join this match, probably because you\'re the host'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    ));
                          }
                        }),
                      )
                    ],
                  );
              }
            }),
      ),
    );
  }
}
