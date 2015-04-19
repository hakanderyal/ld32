import math

import csfml, csfml_ext

import fnf.resources
import fnf.scene_graph

import fnf.entities.aircraft
import fnf.entities.background
import fnf.entities.atomic_stuff

import fnf.ecs.entity
import fnf.commands.commands

import fnf.context

import utils.converters

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

proc addRandomAtomic* (this: World) =
  var rAtomic = newAtomic(AtomicKind.Positive, this.textureHolder)
  rAtomic.position = vec2(this.worldView.size.x/2.0 + random(-250.0..250.0), this.worldBounds.height - this.worldView.size.y/2.0 + random(-250.0..250.0))
  rAtomic.velocity = vec2(random(-50.0..50.0), random(-50.0..50.0))

  var atomicSceneNode = newSceneNode()
  atomicSceneNode.setObj(rAtomic)

  this.addToLayer(lkAir, atomicSceneNode)

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

  var playerSceneNode = newSceneNode()
  playerSceneNode.setObj(this.playerAircraft)

  this.addToLayer(lkAir, playerSceneNode)

  for i in 0..30:
    this.addRandomAtomic()

  # var desertBackground = newBackground(BackgroundKind.Desert, this.textureHolder, rect(this.worldBounds))
  # desertBackground.texture.repeated = true

  # desertBackground.position = vec2(this.worldBounds.left, this.worldBounds.top)
  # var desertBackgroundSceneNode = newSceneNode()
  # desertBackgroundSceneNode.setObj(desertBackground)

  # this.addToLayer(lkBackground, desertBackgroundSceneNode)

proc draw* (this: World) =
  this.window.view = this.worldView
  this.window.draw(this.sceneGraph)

proc update* (this: World, dt: Time) =

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

  result.worldView = newView(fRect(vec2(0.0, 0.0), vec2(1200.0, 900.0)))

  result.textureHolder = newTextureMap()

  result.worldBounds = rect(0.0, 0.0, result.worldView.size.x, 2000.0)
  result.spawnPosition = vec2(result.worldView.size.x/2.0, result.worldBounds.height - result.worldView.size.y/2.0)

  result.worldView.center = result.spawnPosition
  result.scrollSpeed = 0

  result.commandQueue = newCommandQueue()

  result.loadTextures()
  result.buildScene()
