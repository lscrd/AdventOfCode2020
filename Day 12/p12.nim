
import std/strutils

type

  # Possible commands.
  Command {.pure.} = enum
    North = "N"
    South = "S"
    East = "E"
    West = "W"
    Left = "L"
    Right = "R"
    Forward = "F"

  # Instruction: command + value.
  Instruction = tuple[command: Command; value: Natural]

  # Coordinates and deltas.
  Coords = tuple[x, y: int]


func manhattanDistance(pos: Coords): Natural =
  ## Return the Manhattan distance from position (0, 0).
  abs(pos.x) + abs(pos.y)


func `+=`(coords: var Coords; delta: Coords) {.inline.} =
  ## Increment a position by a given delta.
  coords.x += delta.x
  coords.y += delta.y


func `*`(delta: Coords; factor: int): Coords {.inline.} =
  ## Multiply a delta by a factor.
  (delta.x * factor, delta.y * factor)


func delta(value, direction: int): Coords =
  ## Compute a delta from a value (magnitude) and a direction.

  case direction
  of 0: (value, 0)
  of 90: (0, value)
  of 180: (-value, 0)
  of 270: (0, -value)
  else: raise newException(ValueError, "wrong direction.")


func rotate(coords: Coords; angle: int): Coords =
  ## Rotate coordinates by a given angle.

  result = case angle
           of 90: (-coords.y, coords.x)
           of 180: (-coords.x, -coords.y)
           of 270: (coords.y, -coords.x)
           else: raise newException(ValueError, "wrong rotation value.")


# Load the instructions.
var instructions : seq[Instruction]
for line in "p12.data".lines:
  let command = parseEnum[Command](line[0..0])
  let value = line[1..^1].parseInt().Natural
  instructions.add (command, value)


### Part 1 ###

func run1(instructions: seq[Instruction]): Coords =
  ## Apply the instructions with the first meaning of commands.

  var direction: Natural = 0  # 0 = East, 90 = North, 180 = West, 270 = South.

  for (command, value) in instructions:
    case command
    of North: result += (0, value)
    of South: result += (0, -value)
    of East: result += (value, 0)
    of West: result += (-value, 0)
    of Left: direction = (direction + value) mod 360
    of Right: direction = (direction + 360 - value) mod 360
    of Forward: result += delta(value, direction)


echo "Part 1: ", instructions.run1().manhattanDistance()


### Part 2 ###

func run2(instructions: seq[Instruction]): Coords =
  ## Apply the instructions with the second meaning of commands.

  var wayPoint: Coords = (x: 10, y: 1)

  for (command, value) in instructions:
    case command
    of North: wayPoint += (0, value)
    of South: wayPoint += (0, -value)
    of East: wayPoint += (value, 0)
    of West: wayPoint += (-value, 0)
    of Left: wayPoint = wayPoint.rotate(value)
    of Right: wayPoint = wayPoint.rotate(360 - value)
    of Forward: result += wayPoint * value


echo "Part 2: ", instructions.run2().manhattanDistance()
