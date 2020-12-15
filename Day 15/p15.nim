import tables

const Init = [6, 19, 0, 5, 7, 13, 1]


func play(init: openArray[int]; n: int): int =
  ## Play "n" turns of the game starting from "init".

  var ranks: Table[int, int]
  for i, val in init[0..^2]:
    ranks[val] = i + 1

  var last = init[^1]     # Last value announced, not yet memorized.
  var turn = init.len

  for _ in (turn+1)..n:
    var next = ranks.getOrDefault(last, 0)
    if next != 0: next = turn - next
    ranks[last] = turn    # Now, memorize the previous value.
    last = next           # Announce the new value.
    inc turn

  result = last


echo "Part 1: ", play(Init, 2020)
echo "Part 2: ", play(Init, 30000000)
