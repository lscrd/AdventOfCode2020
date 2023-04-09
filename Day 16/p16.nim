import std/[sequtils, strscans, strutils, tables]

type
  Ranges = array[2, Slice[int]]
  Rules = Table[string, Ranges]
  Ticket = seq[int]
  Tickets = seq[Ticket]

# Read and split input file in three strings: rules, my ticket and nearby tickets.
let data = "p16.data".readFile().split("\n\n")

# Parse rules and build rules table.
var rules: Rules
for line in data[0].splitLines():
  var name: string
  var a, b, c, d: int
  if line.scanf("$+: $i-$i or $i-$i", name, a, b, c, d):
    rules[name] = [a..b, c..d]

# Parse my ticket.
var myTicket: Ticket
for line in data[1].splitLines():
  if line.len == 0 or line[0] notin Digits: continue
  myTicket = line.split(',').map(parseInt)

# Parse nearby tickets.
var tickets: Tickets
for line in data[2].splitLines():
  if line.len == 0 or line[0] notin Digits: continue
  tickets.add line.split(',').map(parseInt)


### Part 1 ###

func invalidValue(ticket: Ticket; rules: Rules): int =
  ## Check ticket against rules and return the invalid value or 0 if the ticket is valid.
  for value in ticket:
    block checkValue:
      for ranges in rules.values():
        if value in ranges[0] or value in ranges[1]:
          break checkValue
      # No compatible rule.
      return value

func checkValidity(tickets: Tickets; rules: Rules): tuple[tser: int; tickets: Tickets] =
  ## Check validity of tickets.
  ## Return the "ticket scanning error rate" (TSER) and the list of valid tickets.
  for ticket in tickets:
    let val = ticket.invalidValue(rules)
    result.tser += val
    if val == 0:
      result.tickets.add ticket

# Check validity of nearby tickets.
let (tser, validTickets) = tickets.checkValidity(rules)

echo "Part 1: ", tser


### Part 2 ###

type
  Position = range[0..31]           # Actually range[0..19].
  PosSet = set[Position]
  Positions = Table[string, PosSet]


func update(positions: var Positions; ticket: Ticket; rules: Rules) =
  ## Check ticket against rules and remove impossible positions for rule fields.
  for pos, val in ticket:
    for fieldName, ranges in rules.pairs:
      if val notin ranges[0] and val notin ranges[1]:
        positions[fieldName].excl pos


func value(posSet: PosSet): Position =
  ## Return the first position in a PosSet and in fact the only one
  ## as the set is a singleton.
  for pos in posSet: return pos


func remove(positions: var Positions; pos: Position) =
  ## Remove a position from all positions containing more than one element.
  for fieldName, position in positions.pairs:
    if position.card > 1:
      positions[fieldName].excl pos


func reduce(positions: var Positions) =
  ## Reduce the number of possible positions until they are all singletons.
  var changed = true
  var done: PosSet
  while changed:
    changed = false
    for posSet in positions.values:
      if posSet.card == 1 and not (posSet <= done):
        let pos = posSet.value
        positions.remove pos
        done.incl pos
        changed = true


func fieldPositions(tickets: Tickets; rules: Rules): Positions =
  ## Return the position of fields by examining tickets.

  # Initialize possible positions.
  let maxPos = tickets[0].high
  for fieldName in rules.keys:
    result[fieldName] = {Position(0)..Position(maxPos)}

  # Remove positions by examining each nearby ticket field value.
  for ticket in tickets:
    result.update(ticket, rules)

  # Reduce the number of possible positions to singletons.
  result.reduce()


# Find field positions.
let positions = fieldPositions(validTickets, rules)

# Compute the product of values of fields starting with "departure".
var product = 1
for fieldName, posSet in positions.pairs:
  if fieldName.startswith("departure"):
    product *= myTicket[posSet.value]

echo "Part 2: ", product
