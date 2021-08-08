import 'nonBuilders/game.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupovermelho20211/styles/text.dart';

// Main menu widget, responsible for rendering new game options

//ignore: must_be_immutable
class Match extends StatefulWidget {
  Match({Key? key, required this.matchReference, required this.playerReference})
      : super(key: key);

  final DocumentReference matchReference;
  final DocumentReference playerReference;

  @override
  _MatchState createState() => _MatchState();
}

class _MatchState extends State<Match> {
  late AsyncSnapshot<DocumentSnapshot> lastSnapshot;

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
              var builder;

              if (snapshot.hasData) {
                if (snapshot.hasError) {
                  builder = Text('Error: ${snapshot.error}');
                } else if (snapshot.data?['player_2'] == null) {
                  // If player_2 not joined, stay in waiting state
                  builder = Column(
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
                } else if ((this.lastSnapshot.data?['player_2'] == null) &&
                    (widget.playerReference.id ==
                        this.lastSnapshot.data?['player_1'])) {
                  // If player_2 just joined, player_1 will initialize match
                  var playerDecks = Game.initializeDecks();

                  print(playerDecks);

                  var firstDeck = playerDecks[0];
                  var secondDeck = playerDecks[1];

                  print(firstDeck);
                  print(secondDeck);

                  var playerCards = Game.getCards(firstDeck, secondDeck);
                  var firstCard = playerCards[0];
                  var secondCard = playerCards[1];

                  print(firstCard);
                  print(secondCard);

                  snapshot.data?.reference.update({
                    "round": 1,
                    "player_1_deck": firstDeck,
                    "player_1_card": firstCard,
                    "player_2_deck": secondDeck,
                    "player_2_card": secondCard,
                    "answer": firstCard['number'] * secondCard['number'],
                  });

                  builder = Text('Player found', style: secondaryTextStyle);
                } else if (snapshot.data?['player_1_card'] != null &&
                    snapshot.data?['player_2_card'] != null) {
                  // If cards already sorted, render cards
                  builder = Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(children: [
                          Expanded(
                            flex: 2,
                            child: Game.renderCard(
                                snapshot.data?['player_1_card']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Game.renderCard(
                                snapshot.data?['player_2_card']),
                          )
                        ]),
                        Row(children: [
                          Expanded(child:
                              TextField(onSubmitted: (String value) async {
                            var parsedValue = int.parse(value);

                            if (parsedValue != snapshot.data?['answer']) {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Wrong!'),
                                    content: Text(
                                        'You couldn\'t get the answer right'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Try again'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              if (widget.playerReference.id ==
                                  this.lastSnapshot.data?['player_1']) {
                                snapshot.data?.reference.update({
                                  "player_1_answered_at": new DateTime.now(),
                                });
                              } else {
                                snapshot.data?.reference.update({
                                  "player_2_answered_at": new DateTime.now(),
                                });
                              }
                            }
                          }))
                        ])
                      ],
                    ),
                  );
                }
              }

              this.lastSnapshot = snapshot;
              return builder == null
                  ? Text('Loading...', style: secondaryTextStyle)
                  : builder;
            }),
      ),
    );
  }
}
