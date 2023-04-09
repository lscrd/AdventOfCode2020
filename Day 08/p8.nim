import std/strutils

type
  OpCode = enum opNop = "nop", opAcc = "acc", opJmp = "jmp"
  Instruction = tuple[op: OpCode, val: int]


iterator steps(code: seq[Instruction]): tuple[pc: int16; acc: int] =
  ## Run the program, yielding the PC and accumulator values at each step.

  var pc = 0i16
  var acc = 0
  while true:
    yield (pc, acc)
    if pc >= code.len: break
    case code[pc].op
    of opNop:
      inc pc
    of opAcc:
      inc acc, code[pc].val
      inc pc
    of opJmp:
      inc pc, code[pc].val


var code: seq[Instruction]

# Load the program from file.
for line in "p8.data".lines:
  let fields = line.split(' ')
  code.add (parseEnum[OpCode](fields[0]), parseInt(fields[1]))


### Part 1 ###

proc findLoop(code: seq[Instruction]): int =
  ## Detect first looping instruction and return the accumulator value at this moment.
  var history: set[int16]
  for (pc, acc) in code.steps():
    if pc in history: return acc
    history.incl pc

echo "Part 1: ", code.findLoop()


### Part 2 ###

proc correct(code: var seq[Instruction]): int =
  ## Correct the code and return the value of accumulator after execution.

  # Substitution table.
  const NewOp: array[OpCode, OpCode] = [opJmp, opAcc, opNop]

  for idx in 0..code.high:

    # Change opcode at "idx".
    let prevOp = code[idx].op
    code[idx].op = NewOp[prevOp]

    # Run the modified program.
    var history: set[int16]
    for (pc, acc) in code.steps():
      if pc >= code.len: return acc   # Terminating.
      if pc in history: break         # Looping.
      history.incl pc

    # Restore the previous opcode.
    code[idx].op = prevOp

echo "Part 2: ", code.correct()
