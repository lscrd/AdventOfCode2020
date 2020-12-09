import strutils

const N = 25


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


func sublistWhoseSumIs(list: seq[int]; invalidNumber: int): seq[int] =
  ## Find the first sublist whose sum if equal to the invalid number.
  for i, n in list:
    var r = invalidNumber - n   # Remainder.
    if r <= 0: continue         # First number is too big.
    var j = i
    result = @[n]
    while r > 0:
      inc j
      result.add(list[j])
      dec r, list[j]
    if r == 0:
      return


#———————————————————————————————————————————————————————————————————————————————————————————————————

# Load the list of numbers.
var list: seq[int]
for line in "data".lines:
  list.add(parseInt(line))

let invalidNumber = list.firstInvalidNumber()
let sublist = list.sublistWhoseSumIs(invalidNumber)

echo "Part 1: ", invalidNumber
echo "Part 2: ", min(sublist) + max(sublist)
