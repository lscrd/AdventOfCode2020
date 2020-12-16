import sequtils, strscans, strutils, tables

type

  Ranges = array[2, Slice[int]]
  Rules = Table[string, Ranges]

  Ticket = seq[int]
  Tickets = seq[Ticket]

  Position = range[0..31]
  PosSet = set[Position]
  Positions = Table[string, PosSet]


#---------------------------------------------------------------------------------------------------

func invalidValue(ticket: Ticket; rules: Rules): int =
  ## Check ticket against rules and return the invalid value or 0 if the ticket is valid.

  for value in ticket:
    block checkTicket:
      for ranges in rules.values():
        if value in ranges[0] or value in ranges[1]:
          break checkTicket
      # No compatible rule.
      return value

#---------------------------------------------------------------------------------------------------

func checkValidity(tickets: Tickets; rules: Rules): tuple[tser: int; tickets: Tickets] =
  ## Check validity of tickets.
  ## Return the "ticket scanning error rate" (TSER) and the list of valid tickets.

  for ticket in tickets:
    let val = ticket.invalidValue(rules)
    result.tser += val
    if val == 0:
      result.tickets.add(ticket)

#---------------------------------------------------------------------------------------------------

func update(positions: var Positions; ticket: Ticket; rules: Rules) =
  ## Check ticket against rules and remove impossible positions for rule fields.

  for pos, val in ticket:
    for rule, ranges in rules.pairs:
      if val notin ranges[0] and val notin ranges[1]:
        positions[rule].excl(pos)

#---------------------------------------------------------------------------------------------------

func value(posSet: PosSet): Position =
  ## Return the first position in a PosSet and in fact the only
  ## one as this function is used for sets containing a single position.
  for pos in posSet: return pos

#---------------------------------------------------------------------------------------------------

func remove(positions: var Positions; pos: Position) =
  ## Remove a position from all positions containing more than one element.
  for name, position in positions.pairs:
    if position.card > 1:
      positions[name].excl(pos)

#---------------------------------------------------------------------------------------------------

func reduce(positions: var Positions) =
  ## Reduce the number of possible positions until they are all singletons.

  var changed = true
  var done: PosSet
  while changed:
    changed = false
    for name, posset in positions.pairs:
      if posset.card == 1 and not (posset <= done):
        let pos = posset.value
        positions.remove(pos)
        done.incl(pos)
        changed = true

#---------------------------------------------------------------------------------------------------

func fieldPositions(tickets: Tickets; rules: Rules): Positions =
  ## Return the position of fields by examining tickets.

  # Initialize possible positions.
  let maxpos = tickets[0].high
  for name in rules.keys:
    result[name] = {Position(0)..Position(maxpos)}

  # Remove positions by examining each nearby ticket field value.
  for ticket in tickets:
    result.update(ticket, rules)

  # Reduce the number of possible positions to singletons.
  result.reduce()


#———————————————————————————————————————————————————————————————————————————————————————————————————

# Read and split input file in three strings: rules, my ticket and nearby tickets.
let data = "data".readFile().split("\n\n")

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
  tickets &= line.split(',').map(parseInt)

# Check validity of nearby tickets.
let (tser, validTickets) = tickets.checkValidity(rules)

# Find field positions.
let positions = fieldPositions(validTickets, rules)

# Compute the product of values of fields starting with "departure".
var product = 1
for name, posSet in positions.pairs:
  if name.startswith("departure"):
    product *= myTicket[posSet.value]

echo "Part 1: ", tser
echo "Part 2: ", product
