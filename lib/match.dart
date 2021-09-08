import 'nonBuilders/game.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupovermelho20211/styles/text.dart';
import 'dart:math';

// Match widget, responsible for defining actions based on firestore stream,
// such as rendering cards, computing points and deck managment

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
                } else if (snapshot.data?['winner'] != null) {
                  // If match ended, show message based on player situation (winner or loser)

                  if (widget.playerReference.id == snapshot.data?['winner']) {
                    builder = Text('Congratulations you win!');
                  } else {
                    builder = Text('You lost, you will get it next time =)');
                  }
                } else if (this.lastSnapshot.data?['player_2'] == null &&
                    widget.playerReference.id ==
                        this.lastSnapshot.data?['player_1']) {
                  // If player_2 just joined, player_1 will initialize match
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
                    "player_1_answered_at": null,
                    "player_2_answered_at": null,
                    "answer": firstCard['number'] * secondCard['number'],
                    "winner": null,
                  });

                  builder = Text('Player found', style: secondaryTextStyle);
                } else if (snapshot.data?['player_1_card'] != null &&
                    snapshot.data?['player_2_card'] != null &&
                    snapshot.data?['player_1_answered_at'] == null &&
                    snapshot.data?['player_2_answered_at'] == null) {
                  // If cards already sorted, render cards
                  var answers = [snapshot.data?['answer']];

                  while (answers.length < 3) {
                    // wrong answer in range (2, 100)
                    var wrongAnswer = (new Random().nextInt(9) + 2) *
                        (new Random().nextInt(9) + 2);
                    if (!answers.contains(wrongAnswer)) {
                      answers.add(wrongAnswer);
                    }
                  }
                  answers.shuffle();

                  var score = widget.playerReference.id ==
                          this.lastSnapshot.data?['player_1']
                      ? "YOU: ${snapshot.data?["player_1_deck"].length} x ${snapshot.data?["player_2_deck"].length} OPPONENT"
                      : "YOU: ${snapshot.data?["player_2_deck"].length} x ${snapshot.data?["player_1_deck"].length} OPPONENT";

                  builder = Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                            child: Container(
                                child: Text(
                                  "Round ${this.lastSnapshot.data?['round'] == null ? 1 : this.lastSnapshot.data?['round'] + 1}/7",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 20.0),
                                ),
                                margin: const EdgeInsets.fromLTRB(
                                    0, 0.0, 0, 32.0))),
                        Center(
                            child: Container(
                                child: Text(
                                  score,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 28.0),
                                ),
                                margin: const EdgeInsets.fromLTRB(
                                    0, 0.0, 0, 32.0))),
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
                        getAnswerOptions(answers, snapshot,
                            widget.playerReference.id, context, showDialog)
                      ],
                    ),
                  );
                } else if (((snapshot.data?['player_1_answered_at'] != null &&
                            snapshot.data?['player_2_answered_at'] == null) ||
                        (snapshot.data?['player_2_answered_at'] != null &&
                            snapshot.data?['player_1_answered_at'] == null)) &&
                    widget.playerReference.id ==
                        this.lastSnapshot.data?['player_1']) {
                  // Get's the player that awnsered firsts and updates match decks
                  // Only player_1 will do this process

                  var firstPlayerDeck = snapshot.data?['player_1_deck'];
                  var secondPlayerDeck = snapshot.data?['player_2_deck'];
                  var playerOneCard = snapshot.data?['player_1_card'];
                  var playerTwoCard = snapshot.data?['player_2_card'];

                  if (snapshot.data?['player_1_answered_at'] != null) {
                    firstPlayerDeck.add(playerTwoCard);
                    firstPlayerDeck.shuffle();
                  } else {
                    secondPlayerDeck.add(playerOneCard);
                    secondPlayerDeck.shuffle();
                  }

                  var round = this.lastSnapshot.data?['round'];

                  if (round < 7) {
                    var playerCards =
                        Game.getCards(firstPlayerDeck, secondPlayerDeck);

                    var firstCard = playerCards[0];
                    var secondCard = playerCards[1];

                    snapshot.data?.reference.update({
                      "round": snapshot.data?['round'] + 1,
                      "player_1_deck": firstPlayerDeck,
                      "player_1_card": firstCard,
                      "player_2_deck": secondPlayerDeck,
                      "player_2_card": secondCard,
                      "player_1_answered_at": null,
                      "player_2_answered_at": null,
                      "answer": firstCard['number'] * secondCard['number'],
                    });
                  } else {
                    if (firstPlayerDeck.length > secondPlayerDeck.length) {
                      snapshot.data?.reference.update({
                        "winner": this.lastSnapshot.data?['player_1'],
                      });
                    } else {
                      snapshot.data?.reference.update({
                        "winner": this.lastSnapshot.data?['player_2'],
                      });
                    }
                  }
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

// Widget responsible for rendering options based on anwser

Widget getAnswerOptions(
    List<dynamic> strings, snapshot, id, context, showDialog) {
  return new Row(
      children: strings
          .map((item) => (Container(
              child: new TextButton(
                onPressed: () async {
                  var parsedValue = item;
                  if (parsedValue != snapshot.data?['answer']) {
                    await showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Wrong!'),
                            content: Text('You couldn\'t get the answer right'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Try again'),
                              ),
                            ],
                          );
                        });
                  } else {
                    if (id == snapshot.data?['player_1']) {
                      snapshot.data?.reference.update({
                        "player_1_answered_at": new DateTime.now(),
                      });
                    } else {
                      snapshot.data?.reference.update({
                        "player_2_answered_at": new DateTime.now(),
                      });
                    }
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    primary: Colors.white,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20)),
                child: Text(item.toString(),
                    style: new TextStyle(
                      fontSize: 28.0,
                    )),
              ),
              margin: const EdgeInsets.fromLTRB(8.0, 32.0, 16.0, 0))))
          .toList(),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center);
}
