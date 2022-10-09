# Copyright 2022 EHC + Ecorous
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import std/[
  strutils,
  strformat,
  terminal,
  os
]

const SLOW_TYPING_UNMARKER = "!_!" # 3 in length

template markAsFast*(text: string): string = SLOW_TYPING_UNMARKER & text & SLOW_TYPING_UNMARKER

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