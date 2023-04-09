#[ In this version, we represent the values as unsigned 64 bits integers.
   When dealing directly with bits, we have to take in account the endianness.
]#

import std/[bitops, strmisc, strscans, strutils, tables]

const Bits = 36

type

  Operation = enum opSetMask, opWriteMem
  Value = uint64

  Instruction = object
    case op: Operation
    of opSetMask:
      mask: string      # Mask in big endian representation.
    of opWriteMem:
      address: Natural
      value: Value      # Value in little or big endian representation.

  # Memory is represented by a table as addresses are not contiguous and maybe very high.
  Memory = Table[Natural, Value]

var mem: Memory


proc sum(mem: Memory): Value =
  ## Return the sum of values in memory.
  for value in mem.values:
    result += value

template getMaskElem(mask: string; i: int): char =
  ## Return the mask character at index "i" taking in account the endianness.
  when cpuEndian == bigEndian: mask[i]
  else: mask[^(i+1)]


# Load program.
var program: seq[Instruction]
for line in "p14.data".lines:
  let (head, _, tail) = line.partition(" = ")
  if head == "mask":
    program.add Instruction(op: opSetMask, mask: tail)
  else:
    var address: int
    discard head.scanf("mem[$i]", address)
    program.add Instruction(op: opWriteMem, address: address, value: Value(tail.parseInt()))


### Part 1 ###

proc run1(mem: var Memory; program: seq[Instruction]) =
  ## Run the program using version 1 of decoder chip.

  var mask: string

  for inst in program:
    case inst.op
    of opSetMask:# Load program.
      mask = inst.mask
    of opWriteMem:
      var val = inst.value
      for i in 0..<Bits:
        let c = mask.getMaskElem(i)
        let b = if c == 'X': val.testBit(i) else: c == '1'
        if b: val.setBit(i)
        else: val.clearBit(i)
        mem[inst.address] = val

mem.run1(program)
echo "Part 1: ", sum(mem)


### Part 2 ###

proc expand(mask: string): seq[string] =
  ## Expand a mask containing floating bits to a list of binary strings.

  result = @[mask]
  var idx = 0
  while idx < Bits:
    var next: seq[string]

    # Check bit "idx" of each mask.
    for mask in result:
      if mask[idx] == 'X':
        # Expand the floating bit as two masks.
        next.add mask
        next[^1][idx] = '0'
        next.add mask
        next[^1][idx] = '1'
      else:
        # Keep the mask as is (for now).
        next.add mask

    # Prepare to process next bit.
    inc idx
    result = move(next)

proc run2(mem: var Memory; program: seq[Instruction]) =
  ## Run the program using version 2 of decoder chip.

  var mask: string

  for inst in program:
    case inst.op
    of opSetMask:
      # No need to take in account the endianness as we will not do bit operations.
      mask = inst.mask
    of opWriteMem:
      # Build the address mask by combining address and mask.
      var addressMask = inst.address.toBin(Bits)
      for i, bit in mask:
        if bit != '0': addressMask[i] = bit
      # Expand address mask to addresses and set the values in memory.
      for addressString in addressMask.expand():
        let address = addressString.parseBinInt()
        mem[address] = inst.value

mem.clear()
mem.run2(program)
echo "Part 2: ", sum(mem)
