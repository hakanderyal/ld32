import csfml, csfml_ext
import fnf.ecs.entity
import fnf.resources
import fnf.commands.command_type

type
  PowerCircle* = ref object
    kind*: PowerCircleKind
    radius*: float
    drawable*: CircleShape
  
  PowerCircleKind* {. pure .} = enum
    Positive, Negative

proc toColor(pcKind: PowerCircleKind): Color =
  case pcKind:
  of PowerCircleKind.Positive:
    return color(237,250,242, 50)
  of PowerCircleKind.Negative:
    return color(250,238,237, 50)

proc newPowerCircle*(kind: PowerCircleKind, textureHolder: TextureHolder): PowerCircle =
  new result
  result.kind = kind

  result.drawable = newCircleShape()
  result.drawable.fillColor = kind.toColor
  result.drawable.radius = 225.0
  var bounds = result.drawable.localBounds
  result.drawable.origin = vec2(bounds.width/2, bounds.height/2)

  # result.texture = textureHolder.get(kind.toTextureID).texture

method category* (this: PowerCircle): int =
  # case this.kind:
  # of PowerCircleKind.MainShip:
  #   return ord(CommandType.ctPowerCircle)
  return ord(CommandType.ctPowerCircle)
