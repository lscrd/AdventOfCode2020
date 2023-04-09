import std/strutils

var data: seq[int]
for line in "p1.data".lines():
  data.add line.parseInt()


### Part 1 ###

func part1(data: seq[int]): int =
  for i in 0..<data.high:
    let val = data[i]
    for j in i..data.high:
      if val + data[j] == 2020:
        return val * data[j]

echo "Part 1: ", data.part1()


### Part 2 ###

func part2(data: seq[int]): int =
  for i in 0..(data.high-2):
    let val1 = data[i]
    for j in 1..<data.high:
      let val2 = data[j]
      for k in 2..data.high:
        if val1 + val2 + data[k] == 2020:
          return val1 * val2 * data[k]

echo "Part 2: ", data.part2()
