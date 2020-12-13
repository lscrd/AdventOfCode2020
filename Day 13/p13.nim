import math, strutils

####################################################################################################
# Part 1.

func part1(minTime: int; freqs: seq[int]): int =
  ## Find the minimum starting time.

  var minStart = 2 * minTime    # Initialize at a sufficientlty high value.
  for freq in freqs:
    var start = (minTime div freq) * freq
    if start != minTime: inc start, freq
    if start < minStart:
      minStart = start
      result = (start - minTime) * freq


####################################################################################################
# Part 2.

proc bezoutCoeffs(a, b: int): tuple[u, v: int] =
  ## Return Bezout coefficients, i.e "u" and "v" such as "au + bv = 1".

  if b == 0: return (1, 0)
  let (u, v) = bezoutCoeffs(b, a mod b)
  result = (v, u - (a div b) * v)

#---------------------------------------------------------------------------------------------------

proc part2(freqs, mods: seq[int]): int =
  ## Return the first positive value "n" such that for all "i", "n ≡ mods[i] mod freq[i]".
  ## This uses the Chinese remainder theorem.

  let p = prod(freqs)
  for i, freq in freqs:
    let q = p div freq
    result += mods[i] * bezoutCoeffs(freq, q).v * q
  result = result mod p
  if result < 0: inc result, p


####################################################################################################

# Load data.
let data = "data".readLines(2)
let minTime = data[0].parseInt()
let ids = data[1].split(",")
var freqs: seq[int]
for id in ids:
  if id != "x": freqs.add(id.parseInt())

echo "Part 1: ", part1(minTime, freqs)

# Compute modulos as opposite of ranks.
var mods: seq[int]
for i, id in ids:
  if id != "x": mods.add(-i)

echo "Part 2: ", part2(freqs, mods)
