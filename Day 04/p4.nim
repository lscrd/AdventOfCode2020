import strutils, strscans, tables

type
  Passport = Table[string, string]
  ValidationProc = proc(passport: Passport): bool

const MandatoryFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

#---------------------------------------------------------------------------------------------------

template check(condition: bool): untyped =
  ## Raise an exception if the condition is not fulfilled.
  ## Could not use "assert" as "AssertionError" is deprecated and
  ## "AssertionDefect" should not be caught.
  if not condition: raise newException(ValueError, "")

#---------------------------------------------------------------------------------------------------

func hasMandatoryFields(passport: Passport): bool =
  ## Return true if all mandatory fields are present.

  for field in MandatoryFields:
    if field notin passport:
      return false
  result = true

#---------------------------------------------------------------------------------------------------

func hasValidFields(passport: Passport): bool =
  ## Return true if all mandatory fields are present and contain a valid value.

  result = true
  var val: int

  try:

    let birthYear = passport["byr"]
    check birthYear.len == 4 and birthYear.parseInt() in 1920..2002

    let issueYear = passport["iyr"]
    check issueYear.len == 4 and issueYear.parseInt() in 2010..2020

    let expirationYear = passport["eyr"]
    check expirationYear.len == 4 and expirationYear.parseInt() in 2020..2030

    let height = passport["hgt"]
    check height.scanf("$icm$.", val) and val in 150..193 or
          height.scanf("$iin$.", val) and val in 59..76

    let hairColor = passport["hcl"]
    check hairColor.len == 7 and hairColor.startsWith('#') and
          hairColor[1..^1].allCharsInSet({'a'..'f', '0'..'9'})

    check passport["ecl"] in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

    let pid = passport["pid"]
    check pid.len == 9 and pid.allCharsInSet(Digits)

  except KeyError, ValueError:
    result = false

#---------------------------------------------------------------------------------------------------

proc validPassports(filename: string; isValid: ValidationProc): Natural =
  ## Return the count of valid passwords (according to "isValid" proc) in given file.

  var passport: Passport

  for line in filename.lines:

    if line.strip().len == 0:
      # Passport representation is complete: check validity.
      if passport.isValid(): inc result
      passport.clear()
      continue

    # Process line.
    for field in line.split(' '):
      let keyValue = field.split(':')
      passport[keyValue[0]] = keyValue[1]

  # Check validity of last passport (which is empty if already checked).
  if passport.isValid():
    inc result

#———————————————————————————————————————————————————————————————————————————————————————————————————

echo "Part 1: ", "data".validPassports(hasMandatoryFields)
echo "Part 2: ", "data".validPassports(hasValidFields)
