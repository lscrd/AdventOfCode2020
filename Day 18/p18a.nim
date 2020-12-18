## Simple solution with almost no syntactical checks.
## More complicated than solutions using macros, but less a hack.

type Operator = enum opNone, opAdd, opMul

#---------------------------------------------------------------------------------------------------

template toInt(ch: char): int = ord(ch) - ord('0')

#---------------------------------------------------------------------------------------------------

func update(value: var int; op: Operator; val: int) =
  ## Update a value using an operator.
  case op
  of opNone: value = val
  of opAdd: value += val
  of opMul: value *= val

#---------------------------------------------------------------------------------------------------

func evaluate1(expression: string; start = 0): tuple[val, endIndex: int] =
  ## Evaluate expression starting from "start", with no operator priorities.

  var op = opNone
  var index = start
  var value, val: int

  while index < expression.len:
    let ch = expression[index]
    case ch
    of '+': op = opAdd
    of '*': op = opMul
    of '(':
      (val, index) = expression.evaluate1(index + 1);
      value.update(op, val)
    of ')': return (value, index)
    of '0'..'9': value.update(op, ch.toInt)
    of ' ': discard
    else: raise newException(ValueError, "wrong character: " & ch)

    inc index

  result = (value, index)

#---------------------------------------------------------------------------------------------------

func evaluate2(expression: string; start = 0; term = false): tuple[val, endIndex: int] =
  ## Evaluate expression starting from "start", with reversed operator priorities.

  var op = opNone
  var index = start
  var value, val: int

  while index < expression.len:
    let ch = expression[index]
    case expression[index]
    of '+': op = opAdd
    of '*':
      if term: return (value, index - 1)
      op = opMul
      (val, index) = expression.evaluate2(index + 1, true)
      value *= val
    of '(':
      (val, index) = expression.evaluate2(index + 1)
      value.update(op, val)
    of ')': return (value, if term: index - 1 else: index)
    of '0'..'9': value.update(op, ch.toInt)
    of ' ': discard
    else: raise newException(ValueError, "wrong character: " & ch)

    inc index

  result = (value, index)


#———————————————————————————————————————————————————————————————————————————————————————————————————

var sum = 0
for line in "data".lines:
  sum += line.evaluate1().val
echo "Part 1: ", sum

sum = 0
for line in "data".lines:
  sum += line.evaluate2().val
echo "Part 1: ", sum
