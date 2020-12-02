import strscans, strutils

type ValidationProc = proc(password: string; letter: char; val1, val2: Natural): bool


proc validateCount(password: string; letter: char; min, max: Natural): bool =
  ## Check if there is between "min" and "max" occurrences of "letter" in "password".
  result = password.count(letter) in min..max


proc validatePositions(password: string; letter: char; pos1, pos2: Natural): bool =
  ## Check if "letter" is present in "password" at exactly one of positions "pos1" or "pos2".
  result = password[pos1 - 1] == letter xor password[pos2 - 1] == letter


proc validPasswordsCount(filename: string; isValid: ValidationProc): Natural =
  ## Return the number of valid password according to validation procedure.

  var
    val1, val2: int
    letterString, password: string

  var linenum = 0
  for line in "data".lines:
    inc linenum
    if not line.scanf("$i-$i $w: $+$.", val1, val2, letterString, password):
      raise newException(ValueError, "wrong content at line " & $linenum)
    if letterString.len != 1 or letterString[0] notin Letters:
      raise newException(ValueError, "wrong letter at line " & $linenum)
    if isValid(password, letterString[0], val1, val2):
      inc result


echo "Part 1: ", "data".validPasswordsCount(validateCount)
echo "Part 2: ", "data".validPasswordsCount(validatePositions)
