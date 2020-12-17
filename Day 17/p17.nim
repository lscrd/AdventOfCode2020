# We use 4D coordinates for both parts. In part 1, the w-coordinate is always 0.

import sets

const
  Max =  1_000_000
  Min = -1_000_000

type

  Coords = tuple[x, y, z, w: int]
  CoordSet = HashSet[Coords]

  # Description of active cells.
  ActiveCells = object
    useW: bool            # Use w-coordinate or not.
    deltaW: Slice[int]    # Delta to use for w-coordinate.
    coords: CoordSet      # Coordinates of active cells.

  # Ranges to use when updating state.
  Ranges = tuple[x, y, z, w: Slice[int]]


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
            if (coords.x + dx, coords.y + dy, coords.z + dz, coords.w + dw) in activeCells.coords:
              inc result


func ranges(activeCells: ActiveCells): Ranges =
  ## Return the ranges to use to search for cells to activate or deactivate in next cycle.

  var
    minx, miny, minz, minw = Max
    maxx, maxy, maxz, maxw = Min

  for (x, y, z, w) in activeCells.coords:
    if x < minx: minx = x
    elif x > maxx: maxx = x
    if y < miny: miny = y
    elif y > maxy: maxy = y
    if z < minz: minz = z
    elif z > maxz: maxz = z
    if w < minw: minw = w
    elif w > maxw: maxw = w
    result = ((minx-1)..(maxx+1), (miny-1)..(maxy+1), (minz-1)..(maxz+1), (minw-1)..(maxw+1))

  # Deactivate the w-coordinate if working in 3D.
  if not activeCells.useW: result.w = 0..0


func doCycle(activeCells: var ActiveCells) =
  ## Execute a cycle, updating set of active cells.

  let (xrange, yrange, zrange, wrange) = activeCells.ranges
  var current = activeCells   # Make a copy before updating.

  for x in xrange:
    for y in yrange:
      for z in zrange:
        for w in wrange:
          let coords = (x, y, z, w)
          let actCount = current.activeCount(coords)
          # Update set of active cells.
          if coords in current.coords:
            if actCount notin 2..3:
              activeCells.coords.excl(coords)
          elif actCount == 3:
            activeCells.coords.incl(coords)


#———————————————————————————————————————————————————————————————————————————————————————————————————

var initCoords: CoordSet

# Get the initial coordinates.
var y = 0
for line in "data".lines:
  for x, c in line:
    if c == '#': initCoords.incl((x, y, 0, 0))
  inc y

var activeCells: ActiveCells

activeCells = initActiveCells(initCoords, false)
for _ in 1..6: activeCells.doCycle()
echo "Part1: ", activeCells.coords.len

activeCells = initActiveCells(initCoords, true)
for _ in 1..6: activeCells.doCycle()
echo "Part2: ", activeCells.coords.len
