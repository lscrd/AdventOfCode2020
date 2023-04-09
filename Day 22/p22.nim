import std/[sets, strutils]

type
  Deck = seq[int8]
  Decks = array[1..2, Deck]

var
  decks: Decks
  winner: int

proc loadDecks(filename: string): Decks =
  ## Load decks from a file.
  var idx = 0
  for line in filename.lines:
    if line.startsWith("Player"):
      inc idx
    elif line.len > 0:
      result[idx].add line.parseInt.int8

proc score(deck: Deck): int =
  ## Return the score of a deck.
  for i in 1..deck.len:
    inc result, deck[^i] * i


### Part 1 ###

proc play1(decks: var Decks): int =
  ## Play, using first rules, and return the winner of game.

  while true:

    # Deal cards.
    let card1 = decks[1][0]
    decks[1].delete(0)
    let card2 = decks[2][0]
    decks[2].delete(0)

    # Find winner of round and update decks.
    if card1 > card2:
      decks[1].add card1
      decks[1].add card2
    else:
      decks[2].add card2
      decks[2].add card1

    # Check if game has a winner.
    if decks[2].len == 0:
      return 1
    if decks[1].len == 0:
      return 2


decks = loadDecks("p22.data")
winner = decks.play1()
echo "Part 1: ", decks[winner].score


### Part 2 ###

proc play2(decks: var Decks): int =
  ## Play, using second rules, and return the winner of game.

  var history: HashSet[seq[int8]]
  var winner: int

  while true:

    # Check history.
    let state = decks[1] & 0 & decks[2]
    if state in history:
      return 1
    history.incl state

    # Deal cards.
    let card1 = decks[1][0]
    decks[1].delete(0)
    let card2 = decks[2][0]
    decks[2].delete(0)

    # Find winner of round.
    if decks[1].len >= card1 and decks[2].len >= card2:
      # Enter subgame.
      var copy = [decks[1][0..<card1], decks[2][0..<card2]]
      winner = copy.play2()
    else:
      # Simple comparison of cards.
      winner = if card1 > card2: 1 else: 2

    # Update decks.
    if winner == 1:
      decks[1].add card1
      decks[1].add card2
    else:
      decks[2].add card2
      decks[2].add card1

    # Check if game or subgame has a winner.
    if decks[1].len == 0 or decks[2].len == 0:
      return winner


decks = loadDecks("p22.data")
winner = decks.play2()
echo "Part 2: ", decks[winner].score
