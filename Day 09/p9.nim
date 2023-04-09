import std/strutils

const N = 25

# Load the list of numbers.
var list: seq[int]
for line in "p9.data".lines:
  list.add line.parseInt()


### Part 1 ###

func firstInvalidNumber(list: seq[int]): int =
  ## Return the first invalid number in the list.
  for i in N..list.high:
    let p = list[(i - N)..(i - 1)]  # N previous values.
    let n = list[i]
    var valid = false
    for val in p:
      if n - val in p and val != n - val:
        valid = true
        break
    if not valid:
      return n

let invalidNumber = list.firstInvalidNumber()
echo "Part 1: ", invalidNumber


### Part 2 ###

func sublistWhoseSumIs(list: seq[int]; invalidNumber: int): seq[int] =
  ## Find the first sublist whose sum if equal to the invalid number.
  for i, n in list:
    var r = invalidNumber - n   # Remainder.
    if r <= 0: continue         # First number is too big.
    var j = i
    result = @[n]
    while r > 0:
      inc j
      result.add list[j]
      dec r, list[j]
    if r == 0:
      return

let sublist = list.sublistWhoseSumIs(invalidNumber)
echo "Part 2: ", sublist.min + sublist.max
