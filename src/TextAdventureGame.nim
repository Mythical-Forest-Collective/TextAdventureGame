import std/[
]

import ./utils

slowType("Test! Hello World!")

var testEntity: Entity = Entity.new("john", "doe", 26)
testEntity.say("Hello!")
testEntity.action("<green><green><green><green>You were hit in the face by <fullname><reset>")