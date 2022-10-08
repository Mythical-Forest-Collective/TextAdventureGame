import std/[
  strutils,
  strformat,
  terminal,
  os
]

const SLOW_TYPING_UNMARKER = "!_!" # 3 in length

template markAsFast(text: string): string = SLOW_TYPING_UNMARKER & text & SLOW_TYPING_UNMARKER

# Base entity we inherit from for other entities, like NPCs, Enemies, Player -Blackhole
type Entity* = object of RootObj
  firstName*: string
  lastName*: string
  age*: int


proc slowType*(input: varargs[string], delay: int=80) =
  var text = input.join(" ")

  text = text.multiReplace(
    ("<green>", fgGreen.ansiForegroundColorCode.markAsFast),
    ("<reset>", fgWhite.ansiForegroundColorCode.markAsFast)
  )

  var pos = 0
  var slow = true

  while pos < text.len:
    let character = text[pos]
    if (pos < text.len-3) and (character == '!') and (text[pos+1] == '_') and (text[pos+2] == '!'):
      slow = not slow
      pos += 2
    else:
      stdout.write(character)
      stdout.flushFile()

      if slow:
        sleep(delay)

    pos += 1

  stdout.write('\n')
  stdout.flushFile()


proc new*(_: typedesc[Entity], firstName: string, lastName: string, age: int): Entity =
  return Entity(
    firstName: firstName.capitalizeAscii,
    lastName: lastName.capitalizeAscii,
    age: age
  )


proc say*(entity: Entity, input: varargs[string], delay:int=80) = 
  slowType([fmt"[{entity.firstName}]", input.join(" ")])

# Actions should be slightly faster
proc action*(entity: Entity, input: varargs[string], delay=65) =
  var msg = "*" & input.join(" ") & "*"

  msg = msg.multiReplace(
    ("<name>", entity.firstName),
    ("<lastname>", entity.lastName),
    ("<fullname>", fmt"{entity.firstName} {entity.lastName}")
  )

  slowType(msg, delay=delay)

