# We use 4D coordinates for both parts. In part 1, the w-coordinate is always 0.

import std/[algorithm, sets]

type
  Coords = array[4, int]      # Use an array rather than a tuple.
  CoordSet = HashSet[Coords]

  # Description of active cells.
  ActiveCells = object
    useW: bool            # Use w-coordinate or not.
    deltaW: Slice[int]    # Delta to use for w-coordinate.
    coords: CoordSet      # Coordinates of active cells.

  # Ranges to use when updating state.
  Ranges = array[4, Slice[int]]


func initActiveCells(coords: CoordSet; useW: bool): ActiveCells =
  ## Return an initialized ActiveCells object.
  ActiveCells(useW: useW, deltaw: if useW: -1..1 else: 0..0, coords: coords)


func activeCount(activeCells: ActiveCells; coords: Coords): int =
  ## Return the number of active cells among the neighbor of cell at "coords".
  for dx in -1..1:
    for dy in -1..1:
      for dz in -1..1:
        for dw in activeCells.deltaW:
          if (dx, dy, dz, dw) != (0, 0, 0, 0):
            if [coords[0] + dx, coords[1] + dy,
                coords[2] + dz, coords[3] + dw] in activeCells.coords:
              inc result


func ranges(activeCells: ActiveCells): Ranges =
  ## Return the ranges to use to search for cells to activate or deactivate in next cycle.

  const
    Max =  1_000_000
    Min = -1_000_000

  var minCoords, maxCoords: array[4, int]
  minCoords.fill(Max)
  maxCoords.fill(Min)

  for coords in activeCells.coords:
    for i, coord in coords:
      if coord < minCoords[i]: minCoords[i] = coord
      elif coord > maxCoords[i]: maxCoords[i] = coord

  for i in 0..3:
    result[i] = (minCoords[i] - 1)..(maxCoords[i] + 1)


func doCycle(activeCells: var ActiveCells) =
  ## Execute a cycle, updating set of active cells.

  let r = activeCells.ranges
  var current = activeCells   # Make a copy before updating.

  for x in r[0]:
    for y in r[1]:
      for z in r[2]:
        for w in r[3]:
          let coords = [x, y, z, w]
          let actCount = current.activeCount(coords)
          # Update set of active cells.
          if coords in current.coords:
            if actCount notin 2..3:
              activeCells.coords.excl(coords)
          elif actCount == 3:
            activeCells.coords.incl(coords)


var initCoords: CoordSet

# Get the initial coordinates.
var coords: Coords
for line in "p17.data".lines:
  for c in line:
    if c == '#': initCoords.incl coords
    inc coords[0]
  inc coords[1]
  coords[0] = 0

var activeCells: ActiveCells


### Part 1 ###

activeCells = initActiveCells(initCoords, false)
for _ in 1..6: activeCells.doCycle()
echo "Part1: ", activeCells.coords.len


### Part 2 ###

activeCells = initActiveCells(initCoords, true)
for _ in 1..6: activeCells.doCycle()
echo "Part2: ", activeCells.coords.len
