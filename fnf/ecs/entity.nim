import math, sequtils
import csfml, csfml_ext

import fnf.resources
import fnf.commands.command_type

type
  Entity* = ref object of RootObj
    velocity*: Vector2f
    drawable*: Sprite
    transformable*: Transformable

method category* (this: Entity): int =
  return ord(CommandType.ctScene)

proc newEntity*(): Entity =
  new result
  result.velocity = vec2(0, 0)

## forward declarations
proc `texture=`*(this: Entity, texture: Texture) {.inline.}

method draw*(this: Entity, target: RenderWindow, states: RenderStates) =
  draw(target, this.drawable, states)

proc texture*(this: Entity): auto {.inline.} =
  return this.drawable.texture

proc `texture=`*(this: Entity, texture: Texture) =
  this.drawable.texture = texture
  var bounds = this.drawable.localBounds
  # this.transformable.origin = vec2(bounds.width/2, bounds.height/2)
  this.drawable.origin = vec2(bounds.width/2, bounds.height/2)

# proc `texture=`*(this: Entity, texture: Texture, rectangle: IntRect) =
#   this.drawable.texture = texture
#   var bounds = this.drawable.localBounds
#   # this.transformable.origin = vec2(bounds.width/2, bounds.height/2)
#   this.drawable.origin = vec2(bounds.width/2, bounds.height/2)

proc position*(this: Entity): Vector2f {.inline.} =
  return this.transformable.position

proc `position=`*(this: Entity, position: Vector2f) {.inline.} =
  this.transformable.position = position

proc move*(this: Entity, offset: Vector2f) =
  this.transformable.move(offset)

proc transform*(this: Entity): auto {.inline.} =
  return this.transformable.transform

method update*(this: Entity, deltaTime: Time) =
  this.move(this.velocity * deltaTime.asSeconds)

proc accelerate* (this: Entity, velocity: Vector2f) =
  this.velocity = this.velocity + velocity