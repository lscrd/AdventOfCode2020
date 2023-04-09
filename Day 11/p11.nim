type
  # Area map.
  Area = seq[string]
  # Coordinates.
  Position = tuple[row, col: int]
  # Empty detection rule procedure.
  EmptyRule = proc(area: Area; row, col: int): bool
  # Occupied count rule procedure.
  OccupiedRule = proc(area: Area; row, col: int): int


const
  Floor = '.'
  Empty = 'L'
  Occupied = '#'
  DirectionDeltas = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]


proc simulate(area: Area; isEmpty: EmptyRule; occupiedCount: OccupiedRule; threshold: int): Area =
  ## Simulate using the given rules and the given threshold for occupied seats.

  result = area
  let rowmax = area.high
  let colmax = area[0].high

  var changed = true
  while changed:
    changed = false
    var prevArea = result
    for row in 0..rowmax:
      for col in 0..colmax:
        case prevArea[row][col]
        of Empty:
          if prevArea.isEmpty(row, col):
            result[row][col] = Occupied
            changed = true
        of Occupied:
          if prevArea.occupiedCount(row, col) >= threshold:
            result[row][col] = Empty
            changed = true
        else:
          discard


func occupiedCount(area: Area): int =
  ## Return the number of occupied seats in the whole area.
  for row in area:
    for seat in row:
      if seat == Occupied:
        inc result


# Load the area map.
var area: Area
for line in "p11.data".lines:
  area.add line


### Part 1 ###

iterator adjacentSeats(area: Area; row, col: int): Position =
  ## Yield the row and column positions of adjacent seats.
  let rowMax = area.high
  let colMax = area[0].high
  for (dr, dc) in DirectionDeltas:
    let r = row + dr
    let c = col + dc
    if r in 0..rowMax and c in 0..colMax and area[r][c] != Floor:
      yield (r, c)


func adjacentsAreEmpty(area: Area; row, col: int): bool =
  ## Return true if all adjacents are empty.
  for (r, c) in area.adjacentSeats(row, col):
    if area[r][c] == Occupied:
      return false
  return true


func adjacentOccupiedCount(area: Area; row, col: int): int =
  ## Return the number of occupied adjacent seats.
  for (r, c) in area.adjacentSeats(row, col):
    if area[r][c] == Occupied:
      inc result


let sim1 = area.simulate(adjacentsAreEmpty, adjacentOccupiedCount, 4)
echo "Part 1: ", sim1.occupiedCount()


### Part 2 ###

iterator visibleSeats(area: Area; row, col: int): Position =
  ## Yield the row and column positions of visible seats in the eight directions.
  let rowMax = area.high
  let colMax = area[0].high
  for (dr, dc) in DirectionDeltas:
    var r = row + dr
    var c = col + dc
    while r in 0..rowMax and c in 0..colMax:
      if area[r][c] != Floor:
        yield (r, c)
        break
      inc r, dr
      inc c, dc


func visibleAreEmpty(area: Area; row, col: int): bool =
  ## Return true if all visible seats in the eight directions are empty.
  for (r, c) in area.visibleSeats(row, col):
    if area[r][c] == Occupied:
      return false
  return true


func visibleOccupiedCount(area: Area; row, col: int): int =
  ## Return the number of occupied seats visible in the eight directions.
  for (r, c) in area.visibleSeats(row, col):
    if area[r][c] == Occupied:
      inc result

let sim2 = area.simulate(visibleAreEmpty, visibleOccupiedCount, 5)
echo "Part 2: ", sim2.occupiedCount()
