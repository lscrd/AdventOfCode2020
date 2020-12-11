type

  # Area map.
  Area = seq[string]

  # Empty detection rule procedure.
  EmptyRule = proc(area: Area; row, col: int): bool

  # Occupied count rule procedure.
  OccupiedRule = proc(area: Area; row, col: int): int


const

  Floor = '.'
  Empty = 'L'
  Occupied = '#'

  DirectionDeltas = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]


####################################################################################################
# Rule 1.

iterator adjacentSeats(area: Area; row, col: int): tuple[row, col: int] =
  ## Yield the row and column positions of adjacent seats.

  let rowmax = area.high
  let colmax = area[0].high
  for (dr, dc) in DirectionDeltas:
    let r = row + dr
    let c = col + dc
    if r in 0..rowmax and c in 0..colmax and area[r][c] != Floor:
      yield (r, c)

#---------------------------------------------------------------------------------------------------

func adjacentsAreEmpty(area: Area; row, col: int): bool =
  ## Return true if all adjacents are empty.

  for (r, c) in area.adjacentSeats(row, col):
    if area[r][c] == Occupied:
      return false
  return true

#---------------------------------------------------------------------------------------------------

func adjacentOccupied(area: Area; row, col: int): int =
  ## Return the number of occupied adjacent seats.

  for (r, c) in area.adjacentSeats(row, col):
    if area[r][c] == Occupied:
      inc result


####################################################################################################
# Rule 2.

iterator visibleSeats(area: Area; row, col: int): tuple[row, col: int] =
  ## Yield the row and column positions of visible seats in the eight directions.

  let rowmax = area.high - 1
  let colmax = area[0].high - 1
  for (dr, dc) in DirectionDeltas:
    var r = row
    var c = col
    while r in 1..rowmax and c in 1..colmax:
      inc r, dr
      inc c, dc
      if area[r][c] != Floor:
        yield (r, c)
        break

#---------------------------------------------------------------------------------------------------

func visibleAreEmpty(area: Area; row, col: int): bool =
  ## Return true if all visible seats in the eight directions are empty.

  for (r, c) in area.visibleSeats(row, col):
    if area[r][c] == Occupied:
      return false
  return true

#---------------------------------------------------------------------------------------------------

func visibleOccupied(area: Area; row, col: int): int =
  ## Return the number of occupied seats visible in the eight directions.

  for (r, c) in area.visibleSeats(row, col):
    if area[r][c] == Occupied:
      inc result


####################################################################################################
# Common procedures.

func simulate(area: Area; isEmpty: EmptyRule; occupiedCount: OccupiedRule; threshold: int): Area =
  ## Simulate using the given rules and the given threshold for occupied seats.

  result = area
  let rowmax = area.high
  let colmax = area[0].high

  var changed = true
  while changed:
    changed = false
    var prev = result
    for row in 0..rowmax:
      for col in 0..colmax:
        case prev[row][col]
        of Empty:
          if isEmpty(prev, row, col):
            result[row][col] = Occupied
            changed = true
        of Occupied:
          if occupiedCount(prev, row, col) >= threshold:
            result[row][col] = Empty
            changed = true
        else:
          discard

#---------------------------------------------------------------------------------------------------

func occupiedCount(area: Area): int =
  ## Return the number of occupied seats in the whole area.

  for row in area:
    for seat in row:
      if seat == Occupied:
        inc result


#———————————————————————————————————————————————————————————————————————————————————————————————————

# Load the area map.
var area: Area
for line in "data".lines:
  area.add(line)

let sim1 = area.simulate(adjacentsAreEmpty, adjacentOccupied, 4)
echo "Part 1: ", sim1.occupiedCount()

let sim2 = area.simulate(visibleAreEmpty, visibleOccupied, 5)
echo "Part 2: ", sim2.occupiedCount()
