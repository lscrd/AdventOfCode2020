import std/strutils

func loop(subjectNumber, size: Natural): Natural =
  ## Run the loop "size" times and return the result.
  result = 1
  for i in 1..size:
    result = result * subjectNumber mod 20201227

func loopSize(subjectNumber, target: Natural): Natural =
  ## Find the number of times to run the loop to get the target result.
  var value = 1
  while value != target:
    inc result
    value = value * subjectNumber mod 20201227


### Part 1 ###

let infile = open("p25.data")
let cardPublicKey = infile.readLine().parseInt()
let doorPublicKey = infile.readline().parseInt()
infile.close()

let cardLoopSize = loopSize(7, cardPublicKey)
let doorLoopSize = loopSize(7, doorPublicKey)

let encryptionKey = loop(doorPublicKey, cardLoopSize)
if loop(cardPublicKey, doorLoopSize) == encryptionKey:
  echo "Part 1: ", encryptionKey
else:
  echo "Inconsistency detected."


### Part 2 ###

echo "Part 2: done"
