import csfml, csfml_ext
import fnf.ecs.entity
import fnf.resources
import fnf.commands.command_type

type
  PowerCircle* = ref object of Entity
    kind*: PowerCircleKind
    radius*: float

    isOpen*: bool
    openTimer*: Time
  
  PowerCircleKind* {. pure .} = enum
    Positive, Negative

proc toColor(pcKind: PowerCircleKind): Color =
  case pcKind:
  of PowerCircleKind.Positive:
    return color(237,250,242, 50)
  of PowerCircleKind.Negative:
    return color(250,238,237, 50)

method drawable* (this: PowerCircle): auto =
  return this.internalDrawable.drCircle

method draw*(this: PowerCircle, target: RenderWindow, states: RenderStates) =
  if this.isOpen:
    draw(target, this.internalDrawable.drCircle, states)

  # echo this.openTimer

  # if this.openTimer < microseconds(1000):
  #   this.isOpen = false

method update*(this: PowerCircle, deltaTime: Time) =
  this.openTimer = this.openTimer - deltaTime + microseconds(300)
  if this.openTimer < microseconds(0):
    this.isOpen = false
    this.openTimer = microseconds(0)

proc newPowerCircle*(kind: PowerCircleKind, textureHolder: TextureHolder): PowerCircle =
  new result
  result.kind = kind
  result.setup()

  result.drawable = newCircleShape()
  result.drawable.fillColor = kind.toColor
  result.drawable.radius = 225.0
  var bounds = result.drawable.localBounds
  result.drawable.origin = vec2(bounds.width/2, bounds.height/2)

  result.isOpen = false

  # result.texture = textureHolder.get(kind.toTextureID).texture

method category* (this: PowerCircle): int =
  # case this.kind:
  # of PowerCircleKind.MainShip:
  #   return ord(CommandType.ctPowerCircle)
  return ord(CommandType.ctPowerCircle)

method openPower* (this: PowerCircle, deltaTime: Time) =
  this.isOpen = true
  this.openTimer = deltaTime
