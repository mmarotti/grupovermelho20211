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
                  var playerDecks = Game.initializeDecks();
                  var firstDeck = playerDecks[0];
                  var secondDeck = playerDecks[1];

                  var playerCards = Game.getCards(firstDeck, secondDeck);
                  var firstCard = playerCards[0];
                  var secondCard = playerCards[1];

                  snapshot.data?.reference.update({
                    "round": 1,
                    "player_1_deck": firstDeck,
                    "player_1_card": firstCard,
                    "player_2_deck": secondDeck,
                    "player_2_card": secondCard,
                    "answer": firstCard * secondCard,
                  });

                  builder = Text('Player found', style: secondaryTextStyle);
                } else if (snapshot.data?['player_1_card'] != null &&
                    snapshot.data?['player_2_card'] != null) {
                  // builder = Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     Game.renderCard(snapshot.data?['player_1_card']),
                  //     Game.renderCard(snapshot.data?['player_2_card']),
                  //   ],
                  // );

                  builder = Container(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child:
                              Game.renderCard(snapshot.data?['player_1_card']),
                        ),
                        Expanded(
                          child:
                              Game.renderCard(snapshot.data?['player_2_card']),
                        )
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
