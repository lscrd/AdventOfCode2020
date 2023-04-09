import std/[strscans, strutils, tables]

type
  Item = tuple[bag: string; count: int]
  BagContents = Table[string, seq[Item]]


func contains(bagContents: BagContents; container, bag: string): bool =
  ## Return true if "container" contains directly or indirectly "bag".
  for item in bagContents[container]:
    if item.bag == bag or bagContents.contains(item.bag, bag):
      return true


const MyBag = "shiny gold bag"

var bagContents: BagContents

# Parse the lines and build a mapping "bag -> list of (bag, count)".
for line in "p7.data".lines:
  let lineElems = line.split(" contain ")
  let container = lineElems[0][0..^2]     # Ignore trailing 's'.
  bagContents[container] = @[]
  let contentList = lineElems[1][0..^2]   # Ignore trailing '.'.
  if contentList == "no other bags":
    continue
  for content in contentList.split(", "):
    var item: Item
    discard content.scanf("$i $+$.", item.count, item.bag)
    item.bag = item.bag.strip(leading = false, trailing = true, {'s'})  # Remove trailing 's'.
    bagContents[container].add item


### Part 1 ###

var count = 0
for container in bagContents.keys:
  if bagContents.contains(container, MyBag):
    inc count

echo "Part 1: ", count


### Part 2 ###

func bagCount(bagContents: BagContents; bag: string): int =
  ## Return the number of bags contained directly or indirectly in "bag".
  let itemList = bagContents[bag]
  if itemList.len == 0: return
  for item in itemList:
    inc result, item.count
    inc result, item.count * bagContents.bagCount(item.bag)

echo "Part 2: ", bagContents.bagCount(MyBag)
