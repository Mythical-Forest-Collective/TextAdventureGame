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
  sequtils
]

#? Types
type
  Entity* = object
    serializable: Serializable

  #? "Species" of entity, has the components that control the entity and used for serializing
  #? (E.g. in bytes 0 = slime, 1 = banshee. Using a deserializer would return the constant/let)
  Serializable = object
    components: openArray[BaseComponent]

  ComponentTypes = enum
    EmptyComponentType, InfoComponentType, HealthComponentType

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

#? Entity init method
proc init*(_: typedesc[Entity], components: varargs[BaseComponent]): Entity =
  result = Entity(serializable: Serializable(components: components))

#? Component init methods
proc init*(_: typedesc[BaseComponent]): BaseComponent =
  result = BaseComponent()

  result.componentType = EmptyComponentType

proc init*(_: typedesc[InfoComponent], firstName, lastName: string, age: int=0): InfoComponent =
  result = InfoComponent()
  result.firstName = firstName
  result.lastName = lastName
  result.age = age

proc init*(_: typedesc[HealthComponent], maxHealth: int=20, currentHealth: int= -1): HealthComponent =
  result = HealthComponent()

  result.componentType = HealthComponentType
  result.max = maxHealth
  result.current = currentHealth
  if (currentHealth > maxHealth) or (currentHealth < 0):
    result.currentHealth = maxHealth



# Macro that just adds an if check, if the component doesn't exist then you'll get errors
macro ensureComponents(componentTypes: openArray[ComponentTypes], procedure: untyped) =
  echo procedure.treeRepr



# TODO: Create a macro for ensuring that a component exists
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
