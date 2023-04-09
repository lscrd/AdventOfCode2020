import std/[sequtils, strscans, strutils, tables]

type

  RuleKind = enum rChar, rList, rChoice

  Rule = object
    case kind: RuleKind
    of rChar:
      ch: char
    of rList:
      list: seq[int]
    of rChoice:
      list1, list2: seq[int]

  Rules = Table[int, Rule]    # Allows no contiguous rule numbers.


proc load(filename: string): tuple[rules: Rules; messages: seq[string]] =
  ## Load rules and messages from file.

  let data = filename.readFile().split("\n\n")
  let ruleStrings = data[0].splitLines()
  result.messages = data[1].splitLines()

  var num: int
  var str1, str2: string
  for ruleStr in ruleStrings:

    if scanf(ruleStr, "$i: \"$w\"$.", num, str1):
      result.rules[num] = Rule(kind: rChar, ch: str1[0])

    elif scanf(ruleStr, "$i: $+ | $+$.", num, str1, str2):
      let list1 = map(str1.strip().splitWhitespace(), parseInt)
      let list2 = map(str2.strip().splitWhitespace(), parseInt)
      result.rules[num] = Rule(kind: rChoice, list1: list1, list2: list2)

    elif scanf(ruleStr, "$i: $+$.", num, str1):
      let list = map(str1.strip().splitWhitespace(), parseInt)
      result.rules[num] = Rule(kind: rList, list: list)

    else:
      raise newException(ValueError, "Wrong rule: " & ruleStr)


proc check(rules: Rules; msg: string; idx: int; rulenum: int): seq[int] =
  ## Looking at part of "msg" starting at "idx", check if the rule "rulenum"
  ## from "rules" can be satisfied.
  ## Return the list of starting indexes of remaining parts of "msg" after
  ## applying the rule (this is a list as many rules are choices).
  ## If the list is empty, that means that no match was found.

  proc check(rules: Rules; msg: string; idx: int; list: seq[int]): seq[int] =
    ## As the including "check" but with a list of rules instead of a single rule.
    result = @[idx]
    for n in list:
      var indexes: seq[int]
      for index in result:
        indexes.add rules.check(msg, index, n)
      result = move(indexes)

  let rule = rules[rulenum]
  result = case rule.kind
           of rChar:
             if idx < msg.len and msg[idx] == rule.ch: @[idx + 1] else: @[]
           of rList:
             check(rules, msg, idx, rule.list)
           of rChoice:
             check(rules, msg, idx, rule.list1) & check(rules, msg, idx, rule.list2)


proc matches(message: string; rules: Rules): bool =
  ## Return true if "message" matches rule 0 from "rules".
  for index in rules.check(message, 0, 0):
   if index == message.len:
     return true


proc validCount(filename: string): int =
  ## Return the count of valid messages contained in file.
  let (rules, messages) = filename.load()
  for message in messages:
    if message.len != 0:
      if message.matches(rules):
        inc result


### Part 1 ###
echo "Part 1: ", "p19.data1".validCount

### Part 2 ###
echo "Part 2: ", "p19.data2".validCount
