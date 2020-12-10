import algorithm, strutils

type Differences = array[1..3, Natural]

var outputs: seq[Natural]


func differences(outputs: seq[Natural]): Differences =
  ## Compute the differences between consecutive values.
  var current = 0
  for jolts in outputs:
    inc result[jolts - current]
    current = jolts


func wayCount(outputs: seq[Natural]; target: Natural): Natural =
  ## Count the number of ways to get the target value with the given outputs.

  var counts = newSeq[Natural](target + 1)    # Maps jolt value to number of ways.
  counts[0] = 1
  for newVal in outputs:
    for val in max(newVal - 3, 0)..(newVal - 1):
      inc counts[newVal], counts[val]
  result = counts[target]


#———————————————————————————————————————————————————————————————————————————————————————————————————

# Load data.
for line in "data".lines:
  outputs.add(line.parseInt())

outputs.sort()
outputs.add(outputs[^1] + 3)

# Compute differences and output the requested result.
let diff = outputs.differences
echo "Part 1: ", diff[1] * diff[3]

# Compute the number of ways to connect the adapters.
echo "Part 2: ", outputs.wayCount(outputs[^1])
