import csfml, csfml_ext
import math
import fnf.ecs.entity
import fnf.resources
import fnf.commands.command_type

import fnf.entities.power_circle

import fnf.context

type
  Atomic* = ref object of Entity
    kind*: AtomicKind
    instability*: float
  
  AtomicKind* {. pure .} = enum
    Positive, Negative

proc toTextureID(atomicKind: AtomicKind): TextureID =
  case atomicKind:
  of AtomicKind.Positive:
    return TextureID.AtomicPositive
  of AtomicKind.Negative:
    return TextureID.AtomicNegative

proc newAtomic*(kind: AtomicKind, textureHolder: TextureHolder): Atomic =
  new result
  result.kind = kind
  result.setup()

  result.drawable = newSprite()
  result.texture = textureHolder.get(kind.toTextureID).texture

proc resetTexture*(this: Atomic, textureHolder: TextureHolder) =

  this.texture = textureHolder.get(this.kind.toTextureID).texture

proc resetTexture*(this: Atomic, textureHolder: TextureHolder, textureID: TextureID) =

  this.texture = textureHolder.get(textureID).texture

method category* (this: Atomic): int =
  return ord(CommandType.ctAtomic)

method update*(this: Atomic, deltaTime: Time) =
  this.instability = sqrt(float(this.velocity.x * this.velocity.x) + float(this.velocity.y * this.velocity.y))
  # if this.velocity > 200:

  let borderDistance = 10.0

  if (this.position.x < contextObj.viewBounds.left + borderDistance) or
     (this.position.x > contextObj.viewBounds.left + contextObj.viewBounds.width - borderDistance):
     this.velocity.x = -this.velocity.x

  if (this.position.y < contextObj.viewBounds.top + borderDistance) or
     (this.position.y > contextObj.viewBounds.top + contextObj.viewBounds.height - borderDistance):
     this.velocity.y = -this.velocity.y

  this.move(this.velocity * deltaTime.asSeconds)

method applyForce*(this: Entity, force: Vector2f) =
  this.velocity.x = this.velocity.x + force.x
  this.velocity.y = this.velocity.y + force.y

  if this.velocity.x < 0:
    this.velocity.x = max(-this.maxVelocity, this.velocity.x)
  else:
    this.velocity.x = min(this.maxVelocity, this.velocity.x)

  if this.velocity.y < 0:
    this.velocity.y = max(-this.maxVelocity, this.velocity.y)
  else:
    this.velocity.y = min(this.maxVelocity, this.velocity.y)

method activateCollided*(this: Atomic, textureHolder: TextureHolder) =
  this.kind = AtomicKind.Negative

  this.resetTexture(textureHolder)

method deactivateCollided*(this: Atomic, textureHolder: TextureHolder) =
  this.kind = AtomicKind.Positive

  this.resetTexture(textureHolder)