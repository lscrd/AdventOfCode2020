## Solution using a lexer and inluding checks.
## More complicated but more easily expandable.

type

  Token = enum tkNum, tkAdd, tkMul, tkLpar, tkRpar, tkEnd

  Lexer = object
    expr: string
    pos: int
    token: Token
    value: int


####################################################################################################
# Lexer.

func initLexer(expr: string): Lexer =
  Lexer(expr: expr, pos: -1)

#---------------------------------------------------------------------------------------------------

func next(lexer: var Lexer) =
  ## Scan expression to get next token.

  inc lexer.pos
  while lexer.pos < lexer.expr.len and lexer.expr[lexer.pos] == ' ':
    inc lexer.pos
  if lexer.pos >= lexer.expr.len:
    lexer.token = tkEnd
    return

  let ch = lexer.expr[lexer.pos]
  lexer.token = case ch
                of '+': tkAdd
                of '*': tkMul
                of '(': tkLpar
                of ')': tkRpar
                of '0'..'9': tkNum
                else: raise newException(ValueError, "wrong character: " & ch)

  if lexer.token == tkNum:
    lexer.value = ord(ch) - ord('0')


####################################################################################################
# Evaluation with no operator priorities.

# Forward reference
func evalExpr1(lexer: var Lexer; parenthezised = false): int

#---------------------------------------------------------------------------------------------------

func operand(lexer: var Lexer): int =
  ## Parse aan operand which can be a parenthezised expression or a number.

  if lexer.token == tkLpar:
    lexer.next()
    result = lexer.evalExpr1(true)
  elif lexer.token == tkNum:
    result = lexer.value
  else:
    raise newException(ValueError, "wrong token: " & $lexer.token)

#---------------------------------------------------------------------------------------------------

func evalExpr1(lexer: var Lexer, parenthezised = false): int =
  ## Parse an expression.
  ## If parenthezised, expression must be terminated by a "tkRpar" token.

  result = lexer.operand()
  lexer.next()

  while lexer.token in [tkAdd, tkMul]:
    let token = lexer.token
    lexer.next()
    let val = lexer.operand()
    result = if token == tkAdd: result + val else: result * val
    lexer.next()

  # Check token.
  if parenthezised and lexer.token != tkRpar:
    raise newException(ValueError, "')' expected")
  elif not parenthezised and lexer.token != tkEnd:
    raise newException(ValueError, "wrong token: " & $lexer.token)


####################################################################################################
# Evaluation with reversed operator priorities.

# Forward reference.
func evalExpr2(lexer: var Lexer; parenthezised = false): int

#---------------------------------------------------------------------------------------------------

func evalSimpleExpr(lexer: var Lexer): int =
  ## Parse a simple expression which can be a parenthezised expression or a number.

  if lexer.token == tkLpar:
    lexer.next()
    result = lexer.evalExpr2(true)
  elif lexer.token == tkNum:
    result = lexer.value
  else:
    raise newException(ValueError, "wrong token: " & $lexer.token)

#---------------------------------------------------------------------------------------------------

func evalTerm(lexer: var Lexer): int =
  ## Parse a term, i.e a list of simple expressions separated by '+'.

  result = lexer.evalSimpleExpr()
  lexer.next()
  while lexer.token == tkAdd:
    lexer.next()
    result += lexer.evalSimpleExpr()
    lexer.next()

#---------------------------------------------------------------------------------------------------

func evalExpr2(lexer: var Lexer; parenthezised = false): int =
  ## Parse an expression, i.e. a list fo terms separated by '*'.
  ## If parenthezised, expression must be terminated by a "tkRpar" token.

  result = lexer.evalTerm()
  while lexer.token == tkMul:
    lexer.next()
    result *= lexer.evalTerm()

  # Check token.
  if parenthezised and lexer.token != tkRpar:
    raise newException(ValueError, "')' expected")
  elif not parenthezised and lexer.token != tkEnd:
    raise newException(ValueError, "wrong token: " & $lexer.token)

#———————————————————————————————————————————————————————————————————————————————————————————————————

var sum = 0
for line in "data".lines():
  if line.len != 0:
    var lexer = initLexer(line)
    lexer.next()
    sum += lexer.evalExpr1()
echo "Part 1: ", sum

sum = 0
for line in "data".lines():
  if line.len != 0:
    var lexer = initLexer(line)
    lexer.next()
    sum += lexer.evalExpr2()
echo "Part 2: ", sum
