import math

import csfml, csfml_ext

import fnf.resources
import fnf.scene_graph

import fnf.entities.aircraft
import fnf.entities.background
import fnf.entities.atomic_stuff
import fnf.entities.power_circle

import fnf.ecs.entity
import fnf.commands.commands
import fnf.commands.command_type
import fnf.commands.command_list

import fnf.context

import utils.converters, utils.misc

import sets
import fnf.player

type
  LayerKind* = enum
    lkBackground, lkAir

  Layer* = ref object of SceneNode
    kind: LayerKind

  World* = ref object
    textureHolder: TextureHolder
    
    sceneGraph*: SceneNode
    sceneLayers: seq[ref Layer]

    worldBounds: FloatRect
    spawnPosition: Vector2f
    scrollSpeed*: float

    commandQueue*: CommandQueue

    playerAircraft*: Aircraft

    worldView: View
    window*: RenderWindow

    collisionList: HashSet[Pair[SceneNode, SceneNode]]
    recentlyCollided: HashSet[Pair[SceneNode, SceneNode]]

    player*: Player

proc newLayer*(kind: LayerKind): Layer =
  new result
  result.children = @[]
  result.kind = kind

proc newLayerRef*(kind: LayerKind): ref Layer =
  new result
  result[] = newLayer(kind)

proc loadTextures* (this: World) =
  this.textureHolder.load(TextureID.MainShip, "media/textures/MainShip.png")
  this.textureHolder.load(TextureID.AtomicPositive, "media/textures/AtomicPositive.png")
  this.textureHolder.load(TextureID.AtomicNegative, "media/textures/AtomicNegative.png")
  # this.textureHolder.load(TextureID.Raptor, "media/textures/Raptor.png")
  # this.textureHolder.load(TextureID.Desert, "media/textures/Desert2x.png")

# proc getLayer* (this: seq[ref Layer], kind: LayerKind): ref Layer =

proc addToGraph* (this: World, nodeToAdd: SceneNode, nodeObj: Entity) =

  var aSceneNode = newSceneNode()
  aSceneNode.setObj(nodeObj)
  nodeToAdd.attachChild(aSceneNode)

proc addToLayer* (this: World, kind: LayerKind, node: SceneNode) =

  this.sceneLayers[ord(kind)][].attachChild(node)

proc addRandomAtomic* (this: World, count: int) =
  var rAtomic = newAtomic(AtomicKind.Positive, this.textureHolder)
  var
    randomX = random(-450.0..450.0)
    randomY = random(-450.0..450.0)
  rAtomic.position = vec2(this.worldView.size.x/2.0 + randomX, this.worldBounds.height - this.worldView.size.y/2.0 + randomY)
  rAtomic.velocity = vec2(random(-50.0..50.0), random(-50.0..50.0))

  rAtomic.name = "a" & $count

  var atomicSceneNode = newSceneNode()
  atomicSceneNode.setObj(rAtomic)

  this.addToLayer(lkAir, atomicSceneNode)

proc removeLastAtomic* (this: World) =
  this.sceneLayers[ord(lkAir)].children.delete(high(this.sceneLayers[ord(lkAir)].children)-1)

proc buildScene* (this: World) =
  math.randomize()
  this.sceneGraph = newSceneNode()

  this.sceneLayers = @[]

  for lyKind in LayerKind:
    this.sceneLayers.add(newLayerRef(lyKind))

    this.sceneGraph.attachChild(this.sceneLayers[ord(lyKind)][])

  this.playerAircraft = newAircraft(AircraftKind.MainShip, this.textureHolder)
  # this.playerAircraft.position = vec2(int(this.window.size.x/2), this.window.size.y-150)
  this.playerAircraft.position = this.spawnPosition
  this.playerAircraft.isPlayerOwned = true
  this.playerAircraft.name = "player"

  var playerSceneNode = newSceneNode()
  playerSceneNode.setObj(this.playerAircraft)

  this.addToLayer(lkAir, playerSceneNode)

  this.playerAircraft.powerCircle = newPowerCircle(PowerCircleKind.Positive, this.textureHolder)
  this.playerAircraft.powerCircle.isPlayerOwned = true
  this.playerAircraft.powerCircle.name = "player circle"
  this.addToGraph(playerSceneNode, this.playerAircraft.powerCircle)

  for i in 1..1:
    this.addRandomAtomic(i)

  # var desertBackground = newBackground(BackgroundKind.Desert, this.textureHolder, rect(this.worldBounds))
  # desertBackground.texture.repeated = true

  # desertBackground.position = vec2(this.worldBounds.left, this.worldBounds.top)
  # var desertBackgroundSceneNode = newSceneNode()
  # desertBackgroundSceneNode.setObj(desertBackground)

  # this.addToLayer(lkBackground, desertBackgroundSceneNode)

proc draw* (this: World) =
  this.window.view = this.worldView
  this.window.draw(this.sceneGraph)

proc checkCollisions* (this: World) =
  for item in this.sceneLayers[ord(lkAir)].children:
    item.checkSceneCollision(this.sceneLayers[ord(lkAir)][], this.collisionList)

proc matchTypes (this: var Pair[SceneNode, SceneNode], ct1: CommandType, ct2: CommandType): bool =
  var
    cat1 = this.first.sceneObj.category()
    cat2 = this.second.sceneObj.category()

  if (((cat1 and ord(ct1)) != 0) and ((cat2 and ord(ct2))) != 0):
    return true
  if (((cat1 and ord(ct2)) != 0) and ((cat2 and ord(ct1))) != 0):
    var temp = this.first
    this.first = this.second
    this.second = temp
    return true
  else:
    return false

proc endTurn* (this: World) =
  # for pairs in this.recentlyCollided:
    # Atomic(pairs.first.sceneObj).deactivateCollided(this.textureHolder)
    # Atomic(pairs.second.sceneObj).deactivateCollided(this.textureHolder)

  init(this.recentlyCollided)

proc handleCollisions* (this: World) =
  # echo this.recentlyCollided.len
  for pairs in this.collisionList:
    var vPairs = pairs
    if vPairs.matchTypes(ctAtomic, ctAtomic):
      # echo "atomic & atomic"
      if not this.recentlyCollided.contains(vPairs):

        # var distance = vPairs.first.worldPosition - vPairs.second.worldPosition

        # if distance.x < 0:
        #   distance.x = -distance.x

        # if distance.y < 0:
        #   distance.y = -distance.y

        # distance = distance * 1.3

        # var firstForce = vec2(vPairs.second.sceneObj.velocity.x + distance.x, vPairs.second.sceneObj.velocity.y + distance.y)
        # var secondForce = vec2(vPairs.first.sceneObj.velocity.x + distance.x, vPairs.first.sceneObj.velocity.y + distance.y)

        var firstDistance = vPairs.first.worldPosition - vPairs.second.worldPosition
        var secondDistance = vPairs.second.worldPosition - vPairs.first.worldPosition

        firstDistance = firstDistance * 1.3
        secondDistance = secondDistance * 1.3

        var firstForce = vec2(vPairs.second.sceneObj.velocity.x + firstDistance.x, vPairs.second.sceneObj.velocity.y + firstDistance.y)
        var secondForce = vec2(vPairs.first.sceneObj.velocity.x + secondDistance.x, vPairs.first.sceneObj.velocity.y + secondDistance.y)
        vPairs.first.sceneObj.applyForce(firstForce)
        vPairs.second.sceneObj.applyForce(secondForce)
        this.recentlyCollided.incl(vPairs)
        # Atomic(vPairs.first.sceneObj).activateCollided(this.textureHolder)
        # Atomic(vPairs.second.sceneObj).activateCollided(this.textureHolder)
    if vPairs.matchTypes(ctAtomic, ctPowerCircle):
      if PowerCircle(vPairs.second.sceneObj).isOpen:

        var force = vPairs.first.worldPosition - vPairs.second.worldPosition
        # if this.playerAircraft.velocity.x > 0:
        #   force.x = force.x * this.playerAircraft.velocity.x
        # if this.playerAircraft.velocity.y > 0:
        #   force.y = force.x * this.playerAircraft.velocity.y

        if this.playerAircraft.velocity.x > 0 or this.playerAircraft.velocity.y > 0:
          force = force * 1.1

        force = force * 0.02
        vPairs.first.sceneObj.applyForce(force)
    if vPairs.matchTypes(ctPlayerAircraft, ctAtomic):
      echo "atomic & player"
      discard this.sceneLayers[ord(lkAir)][].detachChild(vPairs.second)
      # vPairs.first.
      discard

    this.collisionList.excl(pairs)

proc update* (this: World, dt: Time) =

  # echo this.collisionList.len

  this.checkCollisions
  this.handleCollisions

  this.worldView.move(vec2(0.0, this.scrollSpeed * dt.asSeconds))
  this.playerAircraft.velocity = vec2(0.0, 0.0)

  let viewBounds = fRect(this.worldView.center - (this.worldView.size / 2.0), this.worldView.size)
  contextObj.viewBounds = viewBounds

  while this.commandQueue.isNotEmpty:
    this.sceneGraph.onCommand(this.commandQueue.pop(), dt)

  var velocity = this.playerAircraft.velocity

  if velocity.x != 0.0 and velocity.y != 0.0:
    this.playerAircraft.velocity = velocity / sqrt(2.0)

  this.playerAircraft.accelerate(vec2(0.0, this.scrollSpeed))

  this.sceneGraph.update(dt)

  ##

  let borderDistance = 40.0

  var position = this.playerAircraft.position

  position.x = max(position.x, viewBounds.left + borderDistance)
  position.x = min(position.x, viewBounds.left + viewBounds.width - borderDistance)
  position.y = max(position.y, viewBounds.top + borderDistance)
  position.y = min(position.y, viewBounds.top + viewBounds.height - borderDistance)

  this.playerAircraft.position = position

proc newWorld*(window: RenderWindow): World =
  new result

  result.window = window
  contextObj = GameContext()
  init(result.collisionList)
  init(result.recentlyCollided)

  result.worldView = newView(fRect(vec2(0.0, 0.0), vec2(1200.0, 900.0)))

  result.textureHolder = newTextureMap()

  result.worldBounds = rect(0.0, 0.0, result.worldView.size.x, 2000.0)
  result.spawnPosition = vec2(result.worldView.size.x/2.0, result.worldBounds.height - result.worldView.size.y/2.0)

  result.worldView.center = result.spawnPosition
  result.scrollSpeed = 0

  result.commandQueue = newCommandQueue()

  result.loadTextures()
  result.buildScene()
