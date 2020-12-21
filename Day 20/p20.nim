import algorithm, math, re, sequtils, strscans, strutils, tables

type

  Position {.pure.} = enum Top, Left, Bottom, Right
  Axis {.pure.} = enum NoAxis, Horizontal, Vertical

  Borders = array[Position, string]   # Four orders.
  BorderTable = Table[int, Borders]   # Mapping tile id -> borders.

  TileInfo = object
    infoSet: bool                     # True if tile info is already set.
    rotation: int                     # Unknown or 0, 1, 2 or 3 × 90°, reverse clockwise.
    flipAxis: Axis                    # NoAxis if not flipping.
    links: array[Position, int]       # Ids of neighbor tiles, None if no neighbor.

  Grid = Table[int, TileInfo]         # Mapping tile id -> tile info.

  Tile = seq[string]
  Tiles = Table[int, Tile]            # Mapping tile id -> tile.

  Image = seq[string]                 # Image represented as a sequence of strings.

  Operation = tuple[angle: int; flipAxis: Axis]


const

  Unknown = -1
  None = 0
  NoMatch = (-1, NoAxis)
  Opposite: array[Position, Position] = [Bottom, Right, Top, Left]
  Axes: array[Position, Axis] = [Vertical, Horizontal, Vertical, Horizontal]

# Sea monsters.
const Monster = ["                  # ",
                 "#    ##    ##    ###",
                 " #  #  #  #  #  #   "]
let Pattern = mapIt(Monster, re(it.replace(' ', '.')))
let MonsterSignCount = sum(mapIt(Monster, it.count('#')))

#---------------------------------------------------------------------------------------------------

proc reversed(s: string): string =
  ## Return the reverse of a string.

  let high = s.high
  result = newString(s.len)
  for i in 0..s.high:
    result[high - i] = s[i]

#---------------------------------------------------------------------------------------------------

func initTileInfo(): TileInfo =
  for item in result.links.mitems: item = Unknown


####################################################################################################
# Functions for part 1.

func getBorders(tile: Tile): Borders =
  ## Return the four borders of a tile.
  ## Borders are returned from left to right for top border, from top to bottom for right border,
  ## from right to left for bottom border and from bottom to top for left border.

  result[Top] = tile[0]
  result[Bottom] = tile[^1]
  result[Bottom].reverse()
  for row in tile:
    result[Left].add(row[0])
    result[Right].add(row[^1])
  result[Left].reverse()

#---------------------------------------------------------------------------------------------------

func rotate(borders: var Borders; angle: int) =
  ## Return the borders after a rotation by an angle of 0°, 90°, 180° or 270°.
  ## Border directions are unchanged.
  if angle != 0:
    borders.rotateLeft(4 - angle)

#---------------------------------------------------------------------------------------------------

func flip(borders: var Borders; axis: Axis) =
  ## Return the borders after flipping horizontaly or verticaly.
  ## Border directions are reversed.
  for item in borders.mitems: item.reverse()
  if axis == Horizontal:
    swap borders[Top], borders[Bottom]
  else:
    swap borders[Left], borders[Right]

#---------------------------------------------------------------------------------------------------

func rotation(pos1, pos2: Position): int =
  ## Return the rotation angle to use to make the side of second tile at "pos2" match
  ## with the side of first tile at position "pos1".
  ## For instance, if "pos1 == Up" and "pos2 == Up", the angle is 2 (180°) as the side
  ## must be at the bottom.
  floorMod(ord(pos1) - ord(pos2) + 2, 4)

#---------------------------------------------------------------------------------------------------

func match(border: string; position: Position; borders: Borders): Operation =
  ## Given a border and its position in a tile, try to find a match with the borders of
  ## another tile. Return the rotation angle and a flipping boolean if a match has been
  ## found. Else return NoMatch.

  for pos in Position:
    # Try a border.
    if borders[pos] == border:
      return (rotation(position, pos), Axes[position])
    # Try the reverse border.
    let rev = reversed(border)
    if borders[pos] == rev:
      return (rotation(position, pos), NoAxis)
    result = NoMatch

#---------------------------------------------------------------------------------------------------

func build(grid: var Grid; borderTable: var BorderTable; id: int) =
  ## Build a grid giving information about each tile, i.e. its neighbors and
  ## the rotation and flip to apply to it.

  #.................................................................................................

  func update(tileInfo: var TileInfo; borders: var Borders; op: Operation) =
    ## Update the tile information and the tile borders according to the
    ## rotation angle and the flip axis (if any) provided by "op".

    tileInfo.infoSet = true
    tileInfo.rotation = op.angle
    borders.rotate(op.angle)
    if op.flipAxis != NoAxis:
      tileInfo.flipAxis = op.flipAxis
      borders.flip(op.flipAxis)

  #.................................................................................................

  # Search for each border of tile "id".
  for pos in Position:
    if grid[id].links[pos] == Unknown:
      # Not yet processed.
      grid[id].links[pos] = None
      let border = borderTable[id][pos]
      for other in borderTable.keys:
        if other == id: continue
        let op = border.match(pos, borderTable[other])
        if op != NoMatch:
          # There is a border match.
          if not grid[other].infoSet:
            # Tile info not yet set.
            update(grid[other], borderTable[other], op)
          # Update links of tiles "id" and "other.
          grid[id].links[pos] = other
          grid[other].links[Opposite[pos]] = id
          # Process the "other" tile.
          grid.build(borderTable, other)
          break


####################################################################################################
# Functions for part 2.

func removeBorders(tile: Tile): Tile =
  ## Remove the four borders of a tile.
  for idx in 1..(tile.len - 2):
    result.add(tile[idx][1..^2])

#---------------------------------------------------------------------------------------------------

func rotate(image: var Image; angle: int) =
  ## Rotate a tile or an image by the given angle.

  var result = newSeq[string](image.len)

  case angle
  of 0:
    return
  of 1:
    for row in image:
      for idx, ch in row:
        result[row.high - idx].add(ch)
  of 2:
    for idx, row in image:
      result[row.high - idx] = reversed(row)
  of 3:
    for row in reversed(image):
      for idx in 0..row.high:
        result[idx].add(row[idx])
  else:
    discard

  image = result

#---------------------------------------------------------------------------------------------------

func flip(image: var seq[string]; axis: Axis) =
  ## Flip a tile or an image along the given axis.

  if axis == Horizontal:
    image.reverse()
  else:
    var result: seq[string]
    for row in image:
      result.add(reversed(row))
    image = result

#---------------------------------------------------------------------------------------------------

func buildImage(tiles: var Tiles; grid: Grid): seq[string] =

  # Loop on the tiles to rotate and flip them and to find the up left tile.
  var tileStart = None
  for id, tileInfo in grid.pairs:
    if tileInfo.links[Top] == None and tileInfo.links[Left] == None:
      tileStart = id
    tiles[id].rotate(tileInfo.rotation)
    if tileInfo.flipAxis != NoAxis:
      tiles[id].flip(tileInfo.flipAxis)

  # Build the image starting from tile with id "tileStart".
  while tileStart != None:
    var tileRow = tiles[tileStart]
    var current = grid[tileStart].links[Right]

    # Add the tiles on the right.
    while current != None:
      # Add a tile to the current tile row.
      for i, row in tiles[current]:
        tileRow[i].add(row)
      current = grid[current].links[Right]

    result.add(tileRow)                           # Add the tile row to the image.
    tileStart = grid[tileStart].links[Bottom]     # Go to next tile row.

#---------------------------------------------------------------------------------------------------

func matches(row: string; pattern: Regex): set[uint8] =
  ## Try to match a row with a pattern.
  ## Return a set of the starting positions.

  var start = 0
  while (let pos = row.find(pattern, start); pos >= 0):
    result.incl(pos.uint8)
    start = pos + 1

#---------------------------------------------------------------------------------------------------

proc matchCount(image: Image): int =
  ## Return the number of matches of the pattern in the image.

  for i in 0..(image.len - 3):
    var s = image[i].matches(Pattern[0])
    if s.card != 0:
      s = s * image[i + 1].matches(Pattern[1])
      if s.card != 0:
        s = s * image[i + 2].matches(Pattern[2])
        inc result, s.card

#---------------------------------------------------------------------------------------------------

proc monsterCount(image: var Image): int =
  ## Return the number of sea monsters in the image.
  ## The image is updated to the right orientation.

  for _ in 1..4:
    result = image.matchCount()
    if result != 0: return
    image.rotate(1)

  image.flip(Horizontal)

  for _ in 1..4:
    result = image.matchCount()
    if result != 0: return
    image.rotate(1)


#———————————————————————————————————————————————————————————————————————————————————————————————————

var
  tiles: Tiles                # Mapping tile id -> tile.
  borderTable: BorderTable    # Mapping tile id -> borders.
  grid: Grid                  # Mapping tile id -> tile info.

# Load tiles.
var num, id: int
for line in "data".lines:
  if line.len == 0: continue
  if line.scanf("Tile $i:", num):
    id = num
    tiles[id] = @[]
  else:
    tiles[id].add(line)

let last = id   # Last id encountered, used to start reconstruction.

# Find the borders.
for id, tile in tiles.pairs:
  borderTable[id] = tile.getBorders()

# Create the TileInfo objects.
for id in tiles.keys:
  grid[id] = initTileInfo()
grid[last].infoSet = true       # This one will not change orientation.
grid.build(borderTable, last)

# Compute the product of the ids of the four corner tiles.
var product = 1
for id, tile in grid.pairs:
  if tile.links[Top] == None or tile.links[Bottom] == None:
    if tile.links[Right] == None or tile.links[Left] == None:
      product *= id

echo "Part 1: ", product

#---------------------------------------------------------------------------------------------------

var image: Image    # The image after reconstruction.

# Remove the borders.
for id, tile in tiles.pairs:
  tiles[id] = tile.removeBorders()

# Build the image using the grid.
image = tiles.buildImage(grid)

# Get the number of sea monsters.
let monsters = image.monsterCount()

# Get the number of '#' in the image.
var totalSigns = 0
for row in image:
  for ch in row:
    if ch == '#': inc totalSigns

echo "Part 2: ", totalSigns - monsters * MonsterSignCount
