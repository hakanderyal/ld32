import math, sequtils
import csfml, csfml_ext

import fnf.resources
import fnf.commands.command_type

type
  EntityKind* {.pure.} = enum
    Sprite, Circle

  Entity* = ref object of RootObj
    velocity*: Vector2f
    maxVelocity*: float
    internalDrawable*: EntityDrawable
    transformable*: Transformable
    isPlayerOwned*: bool
    name*: string

  EntityDrawable = ref object
    case kind*: EntityKind
    of EntityKind.Sprite:
      drSprite*: Sprite
    of EntityKind.Circle:
      drCircle*: CircleShape

# proc drawable* (this: Entity): CircleShape | Sprite =
method drawable* (this: Entity): auto =
  return this.internalDrawable.drSprite

proc `drawable=`* (this: Entity, drawable: Sprite) =
  this.internalDrawable.kind = EntityKind.Sprite
  this.internalDrawable.drSprite = drawable

proc `drawable=`* (this: Entity, drawable: CircleShape) =
  this.internalDrawable.kind = EntityKind.Circle
  this.internalDrawable.drCircle = drawable

method category* (this: Entity): int =
  return ord(CommandType.ctScene)

proc newEntity*(): Entity =
  new result
  result.velocity = vec2(0, 0)

proc setup* (this: Entity) =
  this.internalDrawable = EntityDrawable()
  this.transformable = newTransformable()
  this.isPlayerOwned = false
  this.maxVelocity = 200

## forward declarations
proc `texture=`*(this: Entity, texture: Texture) {.inline.}

method draw*(this: Entity, target: RenderWindow, states: RenderStates) =
  if this.internalDrawable.kind == EntityKind.Sprite:
    draw(target, this.drawable, states)
  else:
    draw(target, this.internalDrawable.drCircle, states)

proc texture*(this: Entity): auto {.inline.} =
  return this.drawable.texture

proc `texture=`*(this: Entity, texture: Texture) =
  this.drawable.texture = texture
  var bounds = this.drawable.localBounds
  # this.transformable.origin = vec2(bounds.width/2, bounds.height/2)
  this.drawable.origin = vec2(bounds.width/2, bounds.height/2)

proc center* (this: Entity): Vector2f =
  var globBounds: FloatRect
  if this.internalDrawable.kind == EntityKind.Sprite:
    globBounds = this.drawable.globalBounds
  else:
    globBounds = this.internalDrawable.drCircle.globalBounds

  # echo "   " & $globBounds

  return vec2(globBounds.left + globBounds.width/2.0, globBounds.top + globBounds.height/2.0)

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

proc textureRect* (this: Entity): auto =
  if this.internalDrawable.kind == EntityKind.Sprite:
    return this.drawable.textureRect
  # else:
  #   return this.internalDrawable.drCircle.size

proc scale* (this: Entity): auto =
  if this.internalDrawable.kind == EntityKind.Sprite:
    return this.drawable.scale
  else:
    return this.internalDrawable.drCircle.scale

proc objRadius* (this: Entity): float =
  if this.internalDrawable.kind == EntityKind.Sprite:
    var orgSize = this.textureRect
    return ((float(orgSize.width) * this.scale.x) + (float(orgSize.height) * this.scale.y)) / 4
  else:
    return this.internalDrawable.drCircle.radius