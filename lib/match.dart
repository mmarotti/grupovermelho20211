import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupovermelho20211/styles/text.dart';
import 'dart:math';

// Main menu widget, responsible for rendering new game options

class Match extends StatefulWidget {
  Match({Key? key, required this.matchReference, required this.playerReference})
      : super(key: key);

  final DocumentReference matchReference;
  final DocumentReference playerReference;

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
                    child: Text('Loading...', style: secondaryTextStyle));
              } else {
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else if (snapshot.data?['player_2'] == null)
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 36),
                        child: SelectableText(
                          'Match ID: ${widget.matchReference.id}',
                          style: primaryTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text('Waiting for second player...',
                          style: secondaryTextStyle)
                    ],
                  );
                else
                  return Text(new Random().nextInt(10).toString());
                /*
                import 'dart:math';
                main() {
                  const suits = ['diamonds', 'clubs', 'hearts', 'spades'];
                  var cards = [];
                  for (var i = 0; i < suits.length; i++) {
                    for( var j = 1 ; j <= 10; j++ ) {
                      var cardName = '${j.toString()} of ${suits[i]}';
                      var randomIndex = new Random().nextInt(cards.length + 1);
                      cards.insert(randomIndex, cardName);
                      }
                  }
                  // print(cards);
                  var player1Cards = cards.sublist(0, 20);
                  var player2Cards = cards.sublist(20);
                }
                 */
              }
            }),
      ),
    );
  }
}
