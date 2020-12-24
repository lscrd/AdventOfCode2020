
import lists

type

  Node = DoublyLinkedNode[int]

  Cups = object
    list: DoublyLinkedRing[int]   # List of values (the cups arranged in a ring).
    nodes: seq[Node]              # Maps node value to node (used to find destination node).
    minLabel: int                 # Min label value.
    maxLabel: int                 # Max label value.

#---------------------------------------------------------------------------------------------------

proc contains(nodes: openArray[Node]; cup: int): bool =
  ## Return true if a value is found in an array/sequence of nodes.
  for node in nodes:
    if cup == node.value:
      return true

#---------------------------------------------------------------------------------------------------

proc initCups1(data: string): Cups =
  ## Initialize the cups according to first rules.

  result.nodes = newSeq[Node](data.len + 1)  # One more to start at index 1.
  result.maxLabel = int.low
  result.minLabel = int.high
  for c in data:
    let cup = ord(c) - ord('0')
    let node = newDoublyLinkedNode(cup)
    result.list.append(node)
    result.nodes[cup] = node
    if cup > result.maxLabel: result.maxLabel = cup
    if cup < result.minLabel: result.minLabel = cup

#---------------------------------------------------------------------------------------------------

proc initCups2(data: string): Cups =
  ## Initialize the cups according to second rules.

  const N = 1_000_000
  result.nodes = newSeq[Node](N + 1)  # One more to start at index 1.
  result.maxLabel = N
  result.minLabel = 1
  # Initialize first node using "data" values.
  for c in data:
    let cup = ord(c) - ord('0')
    let node = newDoublyLinkedNode(cup)
    result.list.append(node)
    result.nodes[cup] = node
  # Complete with successive values.
  for cup in (data.len + 1)..N:
    let node = newDoublyLinkedNode(cup)
    result.list.append(node)
    result.nodes[cup] = node

#---------------------------------------------------------------------------------------------------

proc simulate(cups: var Cups; rounds: int) =
  # Simulate "rounds" rounds of the game.

  var current = cups.list.head
  var threeCups: array[1..3, Node]

  for _ in 1..rounds:

    # Find the three cups to extract and remove them from the list.
    for i in 1..3:
      let node = current.next
      threeCups[i] = node
      cups.list.remove(node)

    # Find the destination value.
    var destination = current.value - 1
    while true:
      if destination < cups.minLabel:
        destination = cups.maxLabel
      if destination notin threeCups:
        break
      dec destination

    # Find the node containing the destination value.
    let destnode = cups.nodes[destination]

    # Insert the three cups after the destination value.
    for i in countdown(3, 1):
      let node = threeCups[i]
      node.next = destnode.next
      node.next.prev = node
      node.prev = destnode
      destnode.next = node

    current = current.next

#---------------------------------------------------------------------------------------------------

proc result1(cups: Cups): string =
  ## Return the result for part 1.

  let nodeOne = cups.nodes[1]
  var node = nodeOne.next
  while node != nodeOne:
    result.add(chr(ord('0') + node.value))
    node = node.next

#---------------------------------------------------------------------------------------------------

proc result2(cups: Cups): int =
  ## Return the result for part 2.

  let nodeOne = cups.nodes[1]
  result = nodeOne.next.value * nodeOne.next.next.value

#———————————————————————————————————————————————————————————————————————————————————————————————————

var cups: Cups

cups = initCups1("586439172")
cups.simulate(100)
echo "Part 1: ", cups.result1()

cups = initCups2("586439172")
cups.simulate(10_000_000)
echo "Part 2: ", cups.result2()
