type
  SeatId = range[0..1023]
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

func maxId(seats: SeatSet): SeatId =
  ## Find the higer seat ID in a set of seat IDs.
  result = SeatId.high
  while result notin seats:
    dec result

func findSeatFrom(seats: SeatSet): SeatId =
  ## Find a seat ID from a set of seat IDs.
  var candidates = {8..1015}   # Ignore first and last row.
  for id in 8..1015:
    if id in seats or id - 1 notin seats or id + 1 notin seats:
      candidates.excl(id)
  assert candidates.card == 1
  for id in candidates:
    return id

#———————————————————————————————————————————————————————————————————————————————————————————————————

var seats: SeatSet
for line in "data".lines:
  seats.incl(seatId(line))

echo "Part 1: ", maxId(seats)
echo "Part 2: ", findSeatFrom(seats)
