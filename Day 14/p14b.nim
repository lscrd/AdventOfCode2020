#[ In this version, we represent the values as strings of '0' and '1'.
   This is less efficient but a bit simpler.
]#

import strmisc, strscans, strutils, tables

const Bits = 36

type

  Operation = enum opSetMask, opWriteMem
  Value = string

  Instruction = object
    case op: Operation
    of opSetMask:
      mask: string
    of opWriteMem:
      address: Natural
      value: Value

  # Memory is represented by a table, as addresses are not contiguous and maybe very high.
  Memory = Table[Natural, Value]

#---------------------------------------------------------------------------------------------------

proc sum(mem: Memory): int =
  ## Return the sum of the values in memory.
  for value in mem.values:
    result += value.parseBinInt()

#---------------------------------------------------------------------------------------------------

proc run1(mem: var Memory; program: seq[Instruction]) =
  ## Run the program using version 1 of decoder chip.

  var mask: string

  for inst in program:
    case inst.op

    of opSetMask:
      mask = inst.mask

    of opWriteMem:
      var val = inst.value
      for i, bit in mask:
        if bit != 'X': val[i] = bit
      mem[inst.address] = val

#---------------------------------------------------------------------------------------------------

proc expand(mask: string): seq[string] =
  ## Expand a mask containing floating bits to a list of binary strings.

  result = @[mask]
  var idx = 0
  while idx < Bits:
    var next: seq[string]

    # Check bit "idx" of each mask.
    for mask in result.items:
      if mask[idx] == 'X':
        # Expand the floating bit in two masks.
        next.add(mask)
        next[^1][idx] = '0'
        next.add(mask)
        next[^1][idx] = '1'
      else:
        # Keep the mask as is (for now).
        next.add(mask)

    # Prepare to process next bit.
    inc idx
    result.shallowCopy(next)

#---------------------------------------------------------------------------------------------------

proc run2(mem: var Memory; program: seq[Instruction]) =
  ## Run the program using version 2 of decoder chip.

  var mask: string

  for inst in program:
    case inst.op

    of opSetMask:
      mask = inst.mask

    of opWriteMem:
      # Build the address mask by combining address and mask.
      var addressMask = inst.address.toBin(Bits)
      for i, bit in mask:
        if bit != '0': addressMask[i] = bit
      # Expand address mask to addresses and set the value in memory.
      for addressString in addressMask.expand():
        let address = addressString.parseBinInt()
        mem[address] = inst.value

#———————————————————————————————————————————————————————————————————————————————————————————————————

# Load program.
var program: seq[Instruction]
for line in "data".lines:
  let (head, _, tail) = line.partition(" = ")
  if head == "mask":
    program.add(Instruction(op: opSetMask, mask: tail))
  else:
    var address: int
    discard head.scanf("mem[$i]", address)
    program.add(Instruction(op: opWriteMem, address: address, value: tail.parseInt.toBin(Bits)))

var mem: Memory
mem.run1(program)
echo "Part 1: ", sum(mem)

mem.clear()
mem.run2(program)
echo "Part 2: ", sum(mem)
