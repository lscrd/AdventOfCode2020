
type Slope = tuple[right, down: int]

var areaMap: seq[string]

for line in "p3.data".lines:
  areaMap.add line


func treeCount(areaMap: seq[string]; slope: Slope): int =
  ## Return the number of trees encountered in the area when using the given slope.

  let rowLen = areaMap.len
  let colLen = areaMap[0].len

  var row, col = 0
  while true:
    col = (col + slope.right) mod colLen
    inc row, slope.down
    if row >= rowLen:
      break
    if areaMap[row][col] == '#':
      inc result

### Part 1 ###

var result =  areaMap.treeCount((3, 1))
echo "Part 1: ", result


### Part 2 ###

for slope in [(1, 1), (5, 1), (7, 1), (1, 2)]:
  result *= areaMap.treeCount(slope)
echo "Part 2: ", result
