import 'package:playing_cards/playing_cards.dart';

class Game {
  static List<List<dynamic>> initializeDecks() {
    const cardNumbers = [2, 3, 4, 5, 6, 7, 8, 9, 10];

    var fullDeck = [
      ...cardNumbers
          .map((cardNumber) => {"number": cardNumber, "suit": 'clubs'}),
      ...cardNumbers
          .map((cardNumber) => {"number": cardNumber, "suit": 'diamonds'}),
      ...cardNumbers
          .map((cardNumber) => {"number": cardNumber, "suit": 'spades'}),
      ...cardNumbers
          .map((cardNumber) => {"number": cardNumber, "suit": 'hearts'}),
    ];

    fullDeck.shuffle();

    var fullDeckLength = fullDeck.length;

    return [
      fullDeck.sublist(
        0,
        (fullDeckLength / 2).round(),
      ),
      fullDeck.sublist(
        (fullDeckLength / 2).round(),
      )
    ];
  }

  static List<dynamic> getCards(
      List<dynamic> firstDeck, List<dynamic> secondDeck) {
    return [
      firstDeck.removeLast(),
      secondDeck.removeLast(),
    ];
  }

  static PlayingCardView renderCard(dynamic card) {
    var value = CardValue.jack;
    var suitValue = Suit.clubs;

    var suit = card['suit'];
    var number = card['number'];

    if (number == 2)
      value = CardValue.two;
    else if (number == 3)
      value = CardValue.three;
    else if (number == 4)
      value = CardValue.four;
    else if (number == 5)
      value = CardValue.five;
    else if (number == 6)
      value = CardValue.six;
    else if (number == 7)
      value = CardValue.seven;
    else if (number == 8)
      value = CardValue.eight;
    else if (number == 9) value = CardValue.nine;

    if (suit == 'clubs')
      suitValue = Suit.clubs;
    else if (suit == 'spades')
      suitValue = Suit.spades;
    else if (suit == 'diamonds')
      suitValue = Suit.diamonds;
    else if (suit == 'hearts') suitValue = Suit.hearts;

    return PlayingCardView(card: PlayingCard(suitValue, value));
  }
}
