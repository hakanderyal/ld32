import csfml, csfml_ext
import fnf.ecs.entity
import fnf.resources
import fnf.commands.command_type

import fnf.entities.power_circle

import fnf.context

type
  Atomic* = ref object of Entity
    kind*: AtomicKind
  
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
  result.transformable = newTransformable()

  result.drawable = newSprite()
  result.texture = textureHolder.get(kind.toTextureID).texture

method category* (this: Atomic): int =
  return ord(CommandType.ctAtomic)

method update*(this: Atomic, deltaTime: Time) =
  let borderDistance = 10.0

  if (this.position.x < contextObj.viewBounds.left + borderDistance) or
     (this.position.x > contextObj.viewBounds.left + contextObj.viewBounds.width - borderDistance):
     this.velocity.x = -this.velocity.x

  if (this.position.y < contextObj.viewBounds.top + borderDistance) or
     (this.position.y > contextObj.viewBounds.top + contextObj.viewBounds.height - borderDistance):
     this.velocity.y = -this.velocity.y

  this.move(this.velocity * deltaTime.asSeconds)