import math, sequtils
import csfml, csfml_ext

import fnf.resources
import fnf.scene_graph
import fnf.entities.aircraft
import fnf.ecs.entity

import fnf.world
import fnf.player

type
  Game* = ref object

    font: Font

    world: World

    statisticsText: Text
    scoreText: Text
    statisticsUpdateTime: Time
    statisticsNumFrames: int64

    PlayerSpeed: float
    TimePerFrame: Time

    player: Player

    showGrid: bool

    isPaused: bool

    isStarted: bool

    grid: seq[RectangleShape]

    window*: RenderWindow

    rShape*: RectangleShape
    rText*: Text

proc increaseSpeed(this: Game) {. noReturn, discardable .} =
  this.world.scrollSpeed = this.world.scrollSpeed - 50.0

proc decreaseSpeed(this: Game) {. noReturn, discardable .} =
  this.world.scrollSpeed = this.world.scrollSpeed + 50.0

proc updateGame(this: Game, deltaTime: Time) {. noReturn, discardable .} =
  this.world.update(deltaTime)
  if int(this.world.instability) > int(this.world.atomics.len * 220):
    for atmc in this.world.atomics:
      atmc.velocity.x = atmc.velocity.x / 1.5
      atmc.velocity.y = atmc.velocity.y / 1.5
    this.world.addRandomAtomic(5)

  if this.world.atomics.len == 0:
    this.world.addRandomAtomic(5)

proc render(this: Game) {. noReturn, discardable .} =
  this.window.clear White
  # this.window.clear Black
  this.world.draw
  this.window.view = this.window.defaultView
  # echo this.window.view == this.window.defaultView
  # this.window.draw this.statisticsText
  this.window.draw this.scoreText
  if this.showGrid:
    for item in this.grid:
      this.window.draw item

  if not this.isStarted:
    this.window.draw this.rShape
    this.window.draw this.rText
  this.window.display

proc processInput(this: Game) =
  var commands = this.world.commandQueue

  var event: Event

  while this.window.pollEvent(event):
    this.player.handleEvent(event, commands)

    case event.kind:
    of EventType.Closed:
      this.window.close()

    of EventType.GainedFocus:
      this.isPaused = false

    of EventType.LostFocus:
      this.isPaused = true

    of EventType.Resized:
      this.world.resize(event)

    of EventType.KeyPressed:
      case event.key.code:
      of KeyCode.Escape:
        this.window.close()
      of KeyCode.Return:
        this.isStarted = not this.isStarted
      of KeyCode.P:
        this.isPaused = not this.isPaused
      # of KeyCode.G:
      #   this.showGrid = not this.showGrid
      # of KeyCode.Num9:
      #   this.world.removeLastAtomic()
      # of KeyCode.Num0:
      #   this.world.addRandomAtomic(1)
      else:
        discard

    else:
      discard

  this.player.handleRealtimeInput(commands)


proc updateStatistics(this: Game, elapsedTime: Time) =
  this.statisticsUpdateTime = this.statisticsUpdateTime + elapsedTime
  this.statisticsNumFrames = this.statisticsNumFrames + 1

  if this.statisticsUpdateTime >= seconds(1.0):
    this.statisticsText.str = 
      # "Frames / Second = " & $this.statisticsNumFrames & "\n" & 
      # "Time / Update = " & $(int(this.statisticsUpdateTime.microseconds) / int(this.statisticsNumFrames)) & "us\n" &
      # "PlayerSpeed = " & $this.PlayerSpeed & "\n" &
      # "PlayerPosition = " & $this.player.position

      "Frames / Second = " & $this.statisticsNumFrames & "\n" & 
      "PlayerPosition = " & $this.world.playerAircraft.position

    this.statisticsUpdateTime = this.statisticsUpdateTime - seconds(1.0)
    this.statisticsNumFrames = 0


proc updateUI(this: Game) =
  this.scoreText.str = "Current Instability\n" & $int(this.world.instability) & "\n" &
    "Required\n" & $int(this.world.atomics.len * 220)


proc run*(this: Game) =
  
  var clock = newClock()
  var timeSinceLastUpdate: Time = Time(microseconds: 0)
  var totalElapsedTime: Time = Time(microseconds: 0)
  var sCount = 0

  while this.window.open:

    var elapsedTime = clock.restart()
    totalElapsedTime = totalElapsedTime + elapsedTime
    timeSinceLastUpdate = timeSinceLastUpdate + elapsedTime
    # timeSinceLastUpdate += clock.restart()

    while timeSinceLastUpdate > this.TimePerFrame:
      # timeSinceLastUpdate -= this.TimePerFrame
      timeSinceLastUpdate = timeSinceLastUpdate - this.TimePerFrame
      this.processInput
      
      if not this.isPaused and this.isStarted:
        if totalElapsedTime > seconds(1):
          # sCount += 1
          totalElapsedTime = Time(microseconds: 0)
          # echo sCount
          this.world.endTurn()
        this.updateGame(this.TimePerFrame)
        this.updateUI

    this.updateStatistics(elapsedTime);
    this.render
    # echo getTotalMem() / 1024


proc newGame*(): Game =
  new result

proc createCell(length: int, positionX: int, positionY: int, size: int): RectangleShape =
  result = newRectangleShape(vec2(length, size))
  result.position = vec2(positionX, positionY)

  if positionY == 0:
    result.rotate(90)

proc createGrid(cellSize: int, windowSize: Vector2f): seq[RectangleShape] =
  result = @[]
  var x = int(windowSize.x)
  var y = int(windowSize.y)
  var numRowsY = int(x / cellSize)
  var numRowsX = int(y / cellSize)
  for k in 0..numRowsX:
    result.add(createCell(x, 0, k*cellSize, 1))

  for i in 0..numRowsY:
    result.add(createCell(y, i*cellSize, 0, 1))

proc setup*(game: var Game) =

  game.window = newRenderWindow(
    videoMode(640*2, 480*2), "NanoX"
  )

  game.world = newWorld(game.window)
  game.player = newPlayer(300)
  game.world.player = game.player

  game.grid = createGrid(50, game.world.window.size)

  game.PlayerSpeed = 200.0
  game.TimePerFrame = seconds(1.0/60.0)

  game.font = newFont("media/Dosis-Light.ttf")
  game.statisticsText = newText()
  game.statisticsText.font = game.font
  game.statisticsText.position = vec2(5.0, float(game.world.window.size.y-60))
  game.statisticsText.characterSize = 20

  game.scoreText = newText()
  game.scoreText.font = game.font
  # game.scoreText.position = vec2(game.world.window.size.x/2 - game.scoreText.globalBounds.width, 20.0)
  game.scoreText.position = vec2(20, 20.0)
  game.scoreText.characterSize = 40

  game.scoreText.color = Black
  game.statisticsText.color = Black

  game.rShape = newRectangleShape()
  game.rShape.size = vec2(game.window.size.x, game.window.size.y)
  game.rShape.fillColor = color(0, 0, 0, 98)

  game.rText = newText()
  game.rText.font = game.font
  game.rText.position = vec2(float(game.world.window.size.x/4), 100.0)
  game.rText.characterSize = 30

  game.rText.str = "Press enter to start." & " \n\n" &
    "Gameplay" & " \n" &
    "Reach the instability level by making atomics(little blue stuff) move faster." & "\n" &
    "Press space to activate you power circle that will push the atomics in range." & "\n" &
    "When you reach instability, new atomics will appear." & "\n" &
    "When you collide with atomic, it will disappear." & "\n" &
    "\n\n" &
    "Controls" & " \n" &
    "W, A, S, D: Move" & " \n" &
    "Space: Activate power circle." & " \n" &
    "P: Pause" & " \n" &
    "Enter: Pause and show this screen" & " \n" &
    "\n\n" &
    "Known Bugs (sorry)" & " \n" &
    "Resizing the window will probably break the game :("  & " \n" &
    "Maximizing the window will definitely lock the game :("  & " \n" 

  game.showGrid = false

  game.isStarted = false
