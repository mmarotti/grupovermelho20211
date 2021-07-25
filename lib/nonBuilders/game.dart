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
}
