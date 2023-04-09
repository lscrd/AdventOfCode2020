type
  SeatId = 0..1023
  SeatSet = set[SeatId]

func decode(str: string; lowChar: char): Natural =
  ## Decode a string coding a row or a column.
  var min = 0
  var max = 1 shl str.len - 1
  for ch in str:
    if ch == lowChar:
      max = (min + max) div 2
    else:
      min = (min + max) div 2 + 1
  assert min == max
  result = min

func seatId(seatCode: string): SeatId =
  ## Find a seat ID from a seat code.
  let row = seatCode[0..6].decode('F')
  let col = seatCode[7..9].decode('L')
  result = row * 8 + col

var seats: SeatSet
for line in "p5.data".lines:
  seats.incl line.seatId


### Part 1 ###

func maxId(seats: SeatSet): SeatId =
  ## Find the higer seat ID in a set of seat IDs.
  result = SeatId.high
  while result notin seats:
    dec result

echo "Part 1: ", seats.maxId


### Part 2 ###

func findSeatFrom(seats: SeatSet): SeatId =
  ## Find a seat ID from a set of seat IDs.
  var candidates = {8..1015}   # Ignore first and last row.
  for id in 8..1015:
    if id in seats or (id - 1) notin seats or (id + 1) notin seats:
      candidates.excl id
  assert candidates.card == 1
  for id in candidates:
    return id

echo "Part 2: ", findSeatFrom(seats)
