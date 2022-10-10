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
  macros,
  sequtils,
  strutils,
  strformat,
  sugar
]

import ./utils

#? Types
type
  NonexistentComponentDefect = object of Defect

  Entity* = object
    serializable: Serializable

  #? "Species" of entity, has the components that control the entity and used for serializing
  #? (E.g. in bytes 0 = slime, 1 = banshee. Using a deserializer would return the constant/let)
  Serializable = object
    components: seq[BaseComponent]

  ComponentTypes = enum
    EmptyComponentType, InfoComponentType, HealthComponentType, ManaComponentType

  #? Components define how an entity behaves.
  BaseComponent* = ref object of RootObj
    componentType: ComponentTypes

#? Custom components
type
  InfoComponent* = ref object of BaseComponent
    firstName*: string
    lastName*: string
    age*: int

  HealthComponent* = ref object of BaseComponent
    max: int
    current: int

  ManaComponent* = ref object of BaseComponent
    max: int
    current: int

#? Nifty procs for component checking
proc componentTypes(s: Serializable): seq[ComponentTypes] = collect(newSeq):
  for component in s.components:
    component.componentType

proc hasComponent(e: Entity, componentType: ComponentTypes): bool =
  result = componentType in e.serializable.componentTypes

proc componentCheck(e: Entity, componentType: ComponentTypes) =
  if not e.hasComponent(InfoComponentType):
    raise newException(NonexistentComponentDefect, fmt"This method does not have the component {$componentType}!")

proc componentCheckAndGet(e: Entity, componentType: ComponentTypes): BaseComponent =
  for component in e.serializable.components:
    if component.componentType == componentType:
      return component

  raise newException(NonexistentComponentDefect, "This method does not have the needed components!")

#? Entity init method
proc init*(_: typedesc[Entity], components: varargs[BaseComponent]): Entity =
  result = Entity(serializable: Serializable(components: components.toSeq))

#? Component init methods
proc init*(_: typedesc[BaseComponent]): BaseComponent =
  result = BaseComponent()

  result.componentType = EmptyComponentType

proc init*(_: typedesc[InfoComponent], firstName, lastName: string, age: int=0): InfoComponent =
  result = InfoComponent()

  result.firstName = firstName
  result.lastName = lastName
  result.age = age

  result.componentType = InfoComponentType

proc init*(_: typedesc[HealthComponent], maxHealth: int=20, currentHealth: int= -1): HealthComponent =
  result = HealthComponent()

  result.max = maxHealth
  result.current = currentHealth
  if (currentHealth > maxHealth) or (currentHealth < 0):
    result.currentHealth = maxHealth

  result.componentType = HealthComponentType

proc init*(_: typedesc[HealthComponent], maxMana: int=20, currentMana: int= -1): ManaComponent =
  result = ManaComponent()

  result.max = maxMana
  result.current = currentMana
  if (currentMana > maxMana) or (currentMana < 0):
    result.currentMana = maxMana

  result.componentType = ManaComponentType

#? So we can access properties of components near seamlessly
# TODO: Implement a macro to automate expanding component properties to entities
#? InfoComponent fields
template firstName*(entity: Entity): string = (entity.componentCheckAndGet(InfoComponentType).InfoComponent).firstName

template lastName*(entity: Entity): string = (entity.componentCheckAndGet(InfoComponentType).InfoComponent).lastName

#? HealthComponent fields
template maxHealth*(entity: Entity): int = (entity.componentCheckAndGet(HealthComponentType).HealthComponentType).max
template `maxHealth=`*(entity: Entity, val: int): int = (entity.componentCheckAndGet(HealthComponentType).HealthComponentType).max = val

template currentHealth*(entity: Entity): int = (entity.componentCheckAndGet(HealthComponentType).HealthComponentType).current
template `currentHealth=`*(entity: Entity, val: int): int = (entity.componentCheckAndGet(HealthComponentType).HealthComponentType).current = val

template curHealth*(entity: Entity): int = entity.currentHealth
template `curHealth=`*(entity: Entity, val: int): int = entity.currentHealth = val

#? ManaComponent fields
template maxMana*(entity: Entity): int = (entity.componentCheckAndGet(ManaComponentType).ManaComponentType).max
template `maxMana=`*(entity: Entity, val: int): int = (entity.componentCheckAndGet(ManaComponentType).ManaComponentType).max = val

template currentMana*(entity: Entity): int = (entity.componentCheckAndGet(ManaComponentType).ManaComponentType).current
template `currentMana=`*(entity: Entity, val: int): int = (entity.componentCheckAndGet(ManaComponentType).ManaComponentType).current = val

template curMana*(entity: Entity): int = entity.currentMana
template `curMana=`*(entity: Entity, val: int): int = entity.currentMana = val

#? Macro that just adds an if check, if the component doesn't exist then you'll get errors, it's clean and easy
#? to use
macro ensureComponents*(componentTypes: openArray[ComponentTypes], procedure: untyped) =
  let entityParamName = procedure[3][1][0]
  procedure[^1].insert(0, quote do:
    for componentType in `componentTypes`:
      componentCheck(`entityParamName`, componentType)
  )
  return procedure

#? Component methods
proc say*(entity: Entity, input: varargs[string], delay:int=80) {.ensureComponents: [InfoComponentType].} = 
  slowType([fmt"[{entity.firstName}]", input.join(" ")])

# Actions should be slightly faster
proc action*(entity: Entity, input: varargs[string], delay=65) {.ensureComponents: [InfoComponentType].} =
  var msg = "*" & input.join(" ") & "*"

  msg = msg.multiReplace(
    ("<name>", entity.firstName),
    ("<lastname>", entity.lastName),
    ("<fullname>", fmt"{entity.firstName} {entity.lastName}")
  )

  slowType(msg, delay=delay)

#? ECS functions
#? The step method is currently unneeded
proc step*(component: BaseComponent, entity: Entity) = discard

proc step*(entity: Entity) =
  for component in entity.serializable.components:
    component.step(entity)

proc init*(_: typedesc[Entity], serializable: Serializable): Entity = 
  result = Entity(serializable: serializable)
