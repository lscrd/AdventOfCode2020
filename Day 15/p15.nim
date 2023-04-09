import std/[sequtils, strutils, tables]

let init = readLines("p15.data", 1)[0].split(',').map(parseInt)


func play(init: seq[int]; n: int): int =
  ## Play "n" turns of the game starting from "init".

  var ranks: Table[int, int]
  for i, val in init[0..^2]:
    ranks[val] = i + 1

  var last = init[^1]     # Last value announced, not yet memorized.
  var turn = init.len

  for _ in (turn + 1)..n:
    var next = ranks.getOrDefault(last, 0)
    if next != 0: next = turn - next
    ranks[last] = turn    # Now, memorize the previous value.
    last = next           # Announce the new value.
    inc turn

  result = last

### Part 1 ###
echo "Part 1: ", play(init, 2020)

### Part 2 ###
echo "Part 2: ", play(init, 30_000_000)
