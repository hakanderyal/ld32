import tables, hashes

import fnf.commands.commands, fnf.commands.command_type
import fnf.scene_graph
import fnf.ecs.entity
import fnf.entities.aircraft

import csfml

type
  PlayerAction = enum
    paMoveLeft, paMoveRight, paMoveUp, paMoveDown

  Player* = ref object
    keyBindings: Table[KeyCode, PlayerAction]
    actions: Table[PlayerAction, Command]

proc aircraftMover*(velocity: Vector2f): Command =
  new result
  result.action = proc (entity: Entity, deltaTime: Time) =
    entity.accelerate(velocity)
  result.category = CommandType.ctPlayerAircraft

proc hash(x: KeyCode | PlayerAction): THash =
  result = ord(x).hash

proc initializeBindings(this: Player) =
  this.keyBindings.add(KeyCode.W, paMoveUp)
  this.keyBindings.add(KeyCode.A, paMoveLeft)
  this.keyBindings.add(KeyCode.S, paMoveDown)
  this.keyBindings.add(KeyCode.D, paMoveRight)

proc initializeActions(this: Player) =

  var playerSpeed = 200.0

  this.actions.add(paMoveLeft, aircraftMover(vec2(-playerSpeed, 0.0)))
  this.actions.add(paMoveRight, aircraftMover(vec2(playerSpeed, 0.0)))
  this.actions.add(paMoveUp, aircraftMover(vec2(0.0, -playerSpeed)))
  this.actions.add(paMoveDown, aircraftMover(vec2(0.0, playerSpeed)))

proc newPlayer*(): Player =
  new result
  result.keyBindings = initTable[KeyCode, PlayerAction]()
  result.actions = initTable[PlayerAction, Command]()

  result.initializeBindings()
  result.initializeActions()

proc handleEvent*(this: Player, event: Event, commandQueue: CommandQueue ) =
  discard

proc isRealTimeAction(action: PlayerAction): bool =
  case action:
  of paMoveDown:
    return true
  of paMoveUp:
    return true
  of paMoveLeft:
    return true
  of paMoveRight:
    return true
  else:
    return false

proc handleRealtimeInput*(this: Player, commandQueue: CommandQueue ) =
  for key, value in this.keyBindings.pairs:
    if keyboardIsKeyPressed(key) and isRealTimeAction(value):
      commandQueue.push(this.actions[value])
  # discard