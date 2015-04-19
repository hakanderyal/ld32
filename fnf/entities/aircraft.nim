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
  result.setup()

  result.drawable = newSprite()
  result.texture = textureHolder.get(kind.toTextureID).texture

method category* (this: Aircraft): int =
  case this.kind:
  of AircraftKind.MainShip:
    return ord(CommandType.ctPlayerAircraft)
  
