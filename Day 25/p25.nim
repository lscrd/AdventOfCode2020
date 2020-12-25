
func loop(subjectNumber, size: Natural): Natural =
  ## Run the loop "size" times and return the result.
  result = 1
  for i in 1..size:
    result *= subjectNumber
    result = result mod 20201227

func loopSize(subjectNumber, target: Natural): Natural =
  ## Find the number of times to run the loop to get the target result.
  var value = 1
  while value != target:
    inc result
    value *= subjectNumber
    value = value mod 20201227

const
  CardPublicKey = 15113849
  DoorPublicKey = 4206373

let cardLoopSize = loopSize(7, CardPublicKey)
let doorLoopSize = loopSize(7, DoorPublicKey)

let encryptionKey = loop(4206373, cardLoopSize)
if loop(15113849, doorLoopSize) == encryptionKey:
  echo "Part 1: ", encryptionKey
else:
  echo "Inconsistency detected"

echo "Part 2: done"
