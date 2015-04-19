import csfml, csfml_ext
import fnf.ecs.entity
import fnf.resources
import fnf.commands.command_type

import fnf.entities.power_circle

type
  Aircraft* = ref object of Entity
    kind*: AircraftKind
    powerCircle*: PowerCircle
  
  AircraftKind* {. pure .} = enum
    MainShip

proc toTextureID(aircraftKind: AircraftKind): TextureID =
  case aircraftKind:
  of AircraftKind.MainShip:
    return TextureID.MainShip

proc newAircraft*(kind: AircraftKind, textureHolder: TextureHolder): Aircraft =
  new result
  result.kind = kind
  result.transformable = newTransformable()

  result.drawable = newSprite()
  result.texture = textureHolder.get(kind.toTextureID).texture
  result.powerCircle = newPowerCircle(PowerCircleKind.Positive, textureHolder)

method draw*(this: Aircraft, target: RenderWindow, states: RenderStates) =
  draw(target, this.powerCircle.drawable, states)
  draw(target, this.drawable, states)

method category* (this: Aircraft): int =
  case this.kind:
  of AircraftKind.MainShip:
    return ord(CommandType.ctPlayerAircraft)
