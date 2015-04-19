import tables, hashes

import fnf.commands.commands, fnf.commands.command_type
import fnf.scene_graph
import fnf.ecs.entity
import fnf.entities.aircraft, fnf.entities.power_circle

import csfml

type
  PlayerAction = enum
    paMoveLeft, paMoveRight, paMoveUp, paMoveDown, paForce

  Player* = ref object
    keyBindings: Table[KeyCode, PlayerAction]
    actions: Table[PlayerAction, Command]
    speed*: float

proc aircraftMover*(velocity: Vector2f): Command =
  new result
  result.action = proc (entity: Entity, deltaTime: Time) =
    entity.accelerate(velocity)
  result.category = CommandType.ctPlayerAircraft

proc openPower*(): Command =
  new result
  result.action = proc (entity: Entity, deltaTime: Time) =
    PowerCircle(entity).openPower(deltaTime)
  result.category = CommandType.ctPowerCircle

proc hash(x: KeyCode | PlayerAction): THash =
  result = ord(x).hash

proc initializeBindings(this: Player) =
  this.keyBindings.add(KeyCode.W, paMoveUp)
  this.keyBindings.add(KeyCode.A, paMoveLeft)
  this.keyBindings.add(KeyCode.S, paMoveDown)
  this.keyBindings.add(KeyCode.D, paMoveRight)
  this.keyBindings.add(KeyCode.Space, paForce)

proc initializeActions(this: Player) =

  var playerSpeed = this.speed

  this.actions.add(paMoveLeft, aircraftMover(vec2(-playerSpeed, 0.0)))
  this.actions.add(paMoveRight, aircraftMover(vec2(playerSpeed, 0.0)))
  this.actions.add(paMoveUp, aircraftMover(vec2(0.0, -playerSpeed)))
  this.actions.add(paMoveDown, aircraftMover(vec2(0.0, playerSpeed)))
  this.actions.add(paForce, openPower())

proc newPlayer*(speed: float): Player =
  new result
  result.speed = speed
  result.keyBindings = initTable[KeyCode, PlayerAction]()
  result.actions = initTable[PlayerAction, Command]()

  result.initializeBindings()
  result.initializeActions()

proc handleEvent*(this: Player, event: Event, commandQueue: CommandQueue ) =
  discard
  # case event.kind:
  #   of EventType.KeyPressed:
  #     case event.key.code:
  #     of KeyCode.Space:
  #       commandQueue.push(this.actions[paForce])
  #     else:
  #       discard
  #   of EventType.KeyReleased:
  #     case event.key.code:
  #     of KeyCode.Space:
  #       commandQueue.push(this.actions[paForce])
  #     else:
  #       discard
  #   else:
  #     discard

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
  of paForce:
    return true
  else:
    return false

proc handleRealtimeInput*(this: Player, commandQueue: CommandQueue ) =
  for key, value in this.keyBindings.pairs:
    if keyboardIsKeyPressed(key) and isRealTimeAction(value):
      commandQueue.push(this.actions[value])
  # discard