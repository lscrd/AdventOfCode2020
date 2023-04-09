import std/[strscans, strutils]

type ValidationProc = proc(password: string; letter: char; val1, val2: Natural): bool


proc validPasswordsCount(filename: string; isValid: ValidationProc): Natural =
  ## Return the number of valid password according to validation procedure.

  var
    val1, val2: int
    letterString, password: string

  var linenum = 0
  for line in filename.lines:
    inc linenum
    if not line.scanf("$i-$i $w: $+$.", val1, val2, letterString, password):
      raise newException(ValueError, "wrong content at line " & $linenum)
    if letterString.len != 1 or letterString[0] notin Letters:
      raise newException(ValueError, "wrong letter at line " & $linenum)
    if password.isValid(letterString[0], val1, val2):
      inc result


### Part 1 ###

proc validateCount(password: string; letter: char; min, max: Natural): bool =
  ## Check if there is between "min" and "max" occurrences of "letter" in "password".
  result = password.count(letter) in min..max

echo "Part 1: ", "p2.data".validPasswordsCount(validateCount)


### Part 2 ###

proc validatePositions(password: string; letter: char; pos1, pos2: Natural): bool =
  ## Check if "letter" is present in "password" at exactly one of positions "pos1" or "pos2".
  result = password[pos1 - 1] == letter xor password[pos2 - 1] == letter

echo "Part 2: ", "p2.data".validPasswordsCount(validatePositions)
