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
    statisticsUpdateTime: Time
    statisticsNumFrames: int64

    PlayerSpeed: float
    TimePerFrame: Time

    player: Player

    showGrid: bool

    isPaused: bool

    grid: seq[RectangleShape]

    window*: RenderWindow

proc increaseSpeed(this: Game) {. noReturn, discardable .} =
  this.world.scrollSpeed = this.world.scrollSpeed - 50.0

proc decreaseSpeed(this: Game) {. noReturn, discardable .} =
  this.world.scrollSpeed = this.world.scrollSpeed + 50.0

proc updateGame(this: Game, deltaTime: Time) {. noReturn, discardable .} =
  this.world.update(deltaTime)

proc render(this: Game) {. noReturn, discardable .} =
  this.window.clear Black
  this.world.draw
  this.window.view = this.window.defaultView
  # echo this.window.view == this.window.defaultView
  this.window.draw this.statisticsText
  if this.showGrid:
    for item in this.grid:
      this.window.draw item
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

    of EventType.KeyPressed:
      case event.key.code:
      of KeyCode.Up:
        this.increaseSpeed()
      of KeyCode.Down:
        this.decreaseSpeed()
      of KeyCode.G:
        this.showGrid = not this.showGrid
      of KeyCode.Num9:
        this.world.removeLastAtomic()
      of KeyCode.Num0:
        this.world.addRandomAtomic(1)
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
      
      if not this.isPaused:
        if totalElapsedTime > seconds(1):
          # sCount += 1
          totalElapsedTime = Time(microseconds: 0)
          # echo sCount
          this.world.endTurn()
        this.updateGame(this.TimePerFrame)

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
    videoMode(640*2, 480*2), "FnF"
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
  game.statisticsText.position = vec2(5.0, 5.0)
  game.statisticsText.characterSize = 20

  game.showGrid = false
