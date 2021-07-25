import 'package:playing_cards/playing_cards.dart';

class Game {
  static List<List<int>> initializeDecks() {
    const cards = [2, 3, 4, 5, 6, 7, 8, 9];
    var fullDeck = [...cards, ...cards, ...cards];

    fullDeck.shuffle();

    return [
      fullDeck.sublist(
        0,
        12,
      ),
      fullDeck.sublist(
        12,
      )
    ];
  }

  static List<int> getCards(List<int> firstDeck, List<int> secondDeck) {
    return [
      firstDeck.removeLast(),
      secondDeck.removeLast(),
    ];
  }

  static PlayingCardView renderCard(int number) {
    var value = CardValue.jack;

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

    return PlayingCardView(card: PlayingCard(Suit.clubs, value));
  }
}
