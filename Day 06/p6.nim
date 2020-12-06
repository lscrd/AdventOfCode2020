import strutils

type CombineMode {.pure.} = enum Any, All


func toSet(str: string): set[char] =
  ## Convert a string to a set of chars.
  for ch in str: result.incl(ch)


proc getYesAnswers(mode: CombineMode): int =
  ## Compute the number of yes answers according to given combine mode.

  let init: set[char] = if mode == Any: {} else: {'a'..'z'}

  var groupAnswers = init
  for line in "data".lines:
    if line.strip().len == 0:
      # End of group.
      inc result, groupAnswers.card
      groupAnswers = init
    else:
      # New person in group.
      case mode
      of Any: groupAnswers = groupAnswers + line.toSet()
      of All: groupAnswers = groupAnswers * line.toSet()

  if groupAnswers.card != 0:
    inc result, groupAnswers.card


echo "Part 1: ", getYesAnswers(Any)
echo "Part 2: ", getYesAnswers(All)
