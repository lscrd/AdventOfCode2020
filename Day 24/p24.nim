import std/[sets, strutils]

type
  Coords = tuple[a, b: int]   # Axial coordinates.
  Vector = tuple[a, b: int]
  Direction {.pure.} = enum East = "e", SouthEast = "se", SouthWest = "sw",
                            West = "w", NorthWest = "nw", NorthEast = "ne"

const Deltas: array[Direction, Vector] = [(1, 0), (0, 1), (-1, 1), (-1, 0), (0, -1), (1, -1)]

type BlackTiles = object
  list: HashSet[Coords]         # Set of of black tiles coordinates.
  mina, maxa, minb, maxb: int   # Minimum and maximum of coordinate values.


func initBlackTiles(): BlackTiles =
  ## Initialize a "BlackTiles" object.
  result.mina = int.high
  result.minb = int.high
  result.maxa = int.low
  result.maxb = int.low

func `+`(coords: Coords; vect: Vector): Coords {.inline.} =
  ## Add a vector to coordinates.
  (coords.a + vect.a, coords.b + vect.b)

func coords(line: string): Coords =
  ## Compute the coordinates from a string.
  result = (0, 0)
  var idx = 0
  var dir: Direction
  while idx < line.len:
    case line[idx]
    of 'e':
      dir = East
    of 'w':
      dir = West
    else:
      dir = parseEnum[Direction](line[idx..(idx+1)])
      inc idx
    result = result + Deltas[dir]
    inc idx

func add(blackTiles: var BlackTiles; coords: Coords) =
  ## Add coordinates to a list of black tiles.
  blackTiles.list.incl coords
  if coords.a < blackTiles.mina: blackTiles.mina = coords.a
  if coords.a > blackTiles.maxa: blackTiles.maxa = coords.a
  if coords.b < blackTiles.minb: blackTiles.minb = coords.b
  if coords.b > blackTiles.maxb: blackTiles.maxb = coords.b

func remove(blackTiles: var BlackTiles; coords: Coords) =
  ## Remove coordinates from a list of black tiles.
  blackTiles.list.excl coords

func count(blackTiles: BlackTiles): int =
  ## Return the number of black tiles.
  blackTiles.list.card

### Part 1 ###

# Build list of black tiles.
var blackTiles = initBlackTiles()
for line in "p24.data".lines:
  if line.len > 0:
    let cell = coords(line)
    if cell in blackTiles.list:
      blackTiles.remove cell
    else:
      blackTiles.add cell
      
echo "Part 1: ", blackTiles.count


### Part 2 ###

iterator neighbors(coords: Coords): Coords =
  ## Yield the coordinates of cells adjacent to a cell.
  for delta in Deltas:
    yield coords + delta

func neighborBlackCount(blackTiles: BlackTiles; coords: Coords): int =
  ## Return the number of black tiles adjacent to a cell.
  for neighbor in coords.neighbors:
    if neighbor in blackTiles.list:
      inc result

proc flip(blackTiles: BlackTiles): BlackTiles =
  ## Return the list of black tiles after flipping.
  result = blackTiles
  for a in (blackTiles.mina - 1)..(blackTiles.maxa + 1):
    for b in (blackTiles.minb - 1)..(blackTiles.maxb + 1):
      let coords = (a, b)
      let count = blackTiles.neighborBlackCount(coords)
      if coords in blackTiles.list:
        if count == 0 or count > 2:
          result.remove coords
      else:
        if count == 2:
          result.add coords


# Flip 100 times.
for _ in 1..100:
  blackTiles = blackTiles.flip()

echo "Part 2: ", blackTiles.count
